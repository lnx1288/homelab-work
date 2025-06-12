#!/bin/bash

# Load shared functions from external script
. functions.sh

# Time interval between building VMs (to avoid race conditions or resource exhaustion)
build_fanout=60

# Adds all the subnets, VLANs, and bridges to the hypervisor based on configuration files
maas_assign_networks()
{
    system_id=$1

    # Get details of the primary physical interface (no parent means it's physical)
    # as per the MAC defined in the hypervisor_mac variable
    phys_int=$(maas ${maas_profile} interfaces read ${system_id} | jq -c ".[] | {id:.id, name:.name, mac:.mac_address, parent:.parents}" | grep "${hypervisor_mac}.*parent.*\[\]")
    phys_int_name=$(echo $phys_int | jq -r .name)
    phys_int_id=$(echo $phys_int | jq -r .id)

    i=0
    for vlan in ${vlans[*]}
    do
        # Retrieve subnet and VLAN info matching configured VLAN ID
        subnet_line=$(maas admin subnets read | jq -rc --arg vlan "$vlan" ".[] | select(.vlan.vid == $vlan) | select(.name | contains(\"/24\"))| {subnet_id:.id, vlan_id:.vlan.id, cidr: .cidr}")
        maas_vlan_id=$(echo $subnet_line | jq -r .vlan_id)
        maas_subnet_id=$(echo $subnet_line | jq -r .subnet_id)
        sub_prefix=$(echo $subnet_line | jq -r .cidr | sed 's/0\/24//g')
        ip_addr=""

        # Determine mode and IP assignment
        if [[ $i -eq 0 ]] ; then
            vlan_int_id=${phys_int_id}
            mode="STATIC"
            ip_addr="ip_address=$hypervisor_ip"
        else
            vlan_int_id=$(maas ${maas_profile} interfaces read ${system_id} | jq --argjson vlan ${vlan} '.[] | select(.vlan.vid == $vlan) | select(.type == "vlan") | .id')
            if [[ -z "$vlan_int_id" ]] ; then
                # Create a new VLAN interface if one doesn't exist
                vlan_int=$(maas ${maas_profile} interfaces create-vlan ${system_id} vlan=${maas_vlan_id} parent=$phys_int_id)
                vlan_int_id=$(echo $vlan_int | jq -r .id)
            fi

            # Set IP address
            mode="STATIC"
            ip_addr="ip_address=${sub_prefix}${ip_suffix}"
        fi

        # Check and create bridge if necessary
        bridge_int=$(maas ${maas_profile} interfaces read ${system_id} | jq --argjson vlan ${vlan} '.[] | select(.vlan.vid == $vlan) | select(.type == "bridge")')
        [[ -z "${bridge_int}" ]] && bridge_int=$(maas ${maas_profile} interfaces create-bridge ${system_id} name=${bridges[$i]} vlan=$maas_vlan_id mac_address=${hypervisor_mac} parent=$vlan_int_id bridge_type=${bridge_type})
        bridge_int_id=$(echo $bridge_int | jq -r .id)

        # Update bridge with subnet link if necessary
        cur_mode=$(echo $bridge_int | jq -r ".links[].mode")
        [[ $cur_mode == "auto" ]] && [[ $mode == "AUTO" ]] && continue

        bridge_link=$(maas ${maas_profile} interface link-subnet $system_id $bridge_int_id mode=${mode} subnet=${maas_subnet_id} ${ip_addr})
        echo $bridge_link
        (( i++ ))
    done
}

# Creates disk partitions and logical volumes for the hypervisor
maas_create_partitions()
{
    system_id=$1
    disks=$(maas ${maas_profile} block-devices read ${system_id})
    size=20  # Size of root logical volume in GB
    actual_size=$(( $size * 1024 * 1024 * 1024 ))

    # Select and set boot disk
    boot_disk=$(echo $disks | jq ".[] | select(.name == \"${disk_names[0]}\") | .id")
    set_boot_disk=$(maas ${maas_profile} block-device set-boot-disk ${system_id} ${boot_disk})

    # Set LVM layout for root disk
    storage_layout=$(maas ${maas_profile} machine set-storage-layout ${system_id} storage_layout=lvm vg_name=${hypervisor_name} lv_name=root lv_size=${actual_size} root_disk=${boot_disk})

    # Allocate remaining space to a new logical volume for libvirt
    vg_device=$(echo $storage_layout | jq ".volume_groups[].id")
    remaining_space=$(maas ${maas_profile} volume-group read ${system_id} ${vg_device} | jq -r ".available_size")
    libvirt_lv=$(maas ${maas_profile} volume-group create-logical-volume ${system_id} ${vg_device} name=libvirt size=${remaining_space})
    libvirt_block_id=$(echo ${libvirt_lv} | jq -r .id)

    # Format and mount the libvirt storage
    stg_fs=$(maas ${maas_profile} block-device format ${system_id} ${libvirt_block_id} fstype=ext4)
    stg_mount=$(maas ${maas_profile} block-device mount ${system_id} ${libvirt_block_id} mount_point=${ceph_storage_path})

    # Create partitions and LVM volume for additional disks
    for ((disk=1;disk<${#disk_names[@]};disk++)); do
        disk_id=$(echo $disks | jq -r ".[] | select(.name == \"${disk_names[$disk]}\") | .id")
        create_partition=$(maas ${maas_profile} partitions create ${system_id} ${disk_id})
        part_id=$(echo $create_partition | jq -r .id)

        if [[ $disk -eq 1 ]] ; then
            vg_create=$(maas ${maas_profile} volume-groups create ${system_id} name=${hypervisor_name}-nvme block_device=${disk_id} partitions=${part_id})
            vg_id=$(echo $vg_create | jq -r .id)
            vg_size=$(echo $vg_create | jq -r .size)
        else
            vg_update=$(maas ${maas_profile} volume-group update ${system_id} ${vg_id} add_partitions=${part_id})
            vg_size=$(echo $vg_update | jq -r .size)
        fi
    done

    # Create, format, and mount logical volume for images
    lv_create=$(maas admin volume-group create-logical-volume ${system_id} ${vg_id} name=images size=${vg_size})
    lv_id=$(echo $lv_create | jq -r .id)
    lv_fs=$(maas ${maas_profile} block-device format ${system_id} ${lv_id} fstype=ext4)
    lv_mount=$(maas ${maas_profile} block-device mount ${system_id} ${lv_id} mount_point=${storage_path})
}

# Adds the hypervisor as a pod to MAAS
maas_add_pod()
{
    pod_create=$(maas ${maas_profile} pods create power_address="qemu+ssh://${virsh_user}@${hypervisor_ip}/system" power_user="${virsh_user}" power_pass="${qemu_password}" type="virsh")
    pod_id=$(echo $pod_create | jq -r .id)
    pod_name=$(maas ${maas_profile} pod update ${pod_id} name=${hypervisor_name})
}

# Removes all associated resources for the hypervisor
wipe_node() {
    install_deps
    maas_login
    destroy_node
}

# Creates a MAAS node for the hypervisor
create_node() {
    install_deps
    maas_login
    maas_add_node ${hypervisor_name} ${hypervisor_mac} physical
}

# Deploys the hypervisor node and adds it as a pod
install_node() {
    install_deps
    maas_login
    deploy_node
    maas_add_pod
}

# Just adds the hypervisor as a pod
add_pod()
{
    install_deps
    maas_login
    maas_add_pod
}

# Configures all networks for the hypervisor
network_auto()
{
    install_deps
    maas_login

    system_id=$(maas_system_id ${hypervisor_name})
    maas_assign_networks ${system_id}
}

# Sets up partitioning for the hypervisor
create_partitions()
{
    install_deps
    maas_login

    system_id=$(maas_system_id ${hypervisor_name})
    maas_create_partitions ${system_id}
}

# Deletes the machine and pod from MAAS
destroy_node() {
    pod_id=$(maas_pod_id ${hypervisor_name})
    pod_delete=$(maas ${maas_profile} pod delete ${pod_id})

    system_id=$(maas_system_id ${hypervisor_name})
    machine_delete=$(maas ${maas_profile} machine delete ${system_id})
}

# Deploys the hypervisor node using cloud-init user-data
deploy_node() {
    system_id=$(maas_system_id ${hypervisor_name})
    maas ${maas_profile} machine deploy ${system_id} user_data="$(base64 user-data.yaml)" > /dev/null

    # Wait for deployment to complete
    ensure_machine_in_state ${system_id} "Deployed"
}

# Displays CLI usage options
show_help() {
  echo "

  -a <node>   Create and Deploy
  -c <node>   Creates Hypervisor
  -d <node>   Deploy Hypervisor
  -k <node>   Add Hypervisor as Pod
  -n <node>   Assign Networks
  -p <node>   Update Partitioning
  -w <node>   Removes Hypervisor
  "
}

# Read configuration values from config files
read_configs

# Parse command-line options
while getopts ":c:w:d:a:k:n:p:" opt; do
  case $opt in
    c)
        read_config "configs/$OPTARG.config"
        create_node
        ;;
    w)
        read_config "configs/$OPTARG.config"
        wipe_node
        ;;
    d)
        read_config "configs/$OPTARG.config"
        install_node
        ;;
    a)
        read_config "configs/$OPTARG.config"
        create_node
        install_node
        ;;
    k)
        read_config "configs/$OPTARG.config"
        add_pod
        ;;
    n)
        read_config "configs/$OPTARG.config"
        network_auto
        ;;
    p)
        read_config "configs/$OPTARG.config"
        create_partitions
        ;;
    \?)
        printf "Unrecognized option: -%s. Valid options are:" "$OPTARG" >&2
        show_help
        exit 1
        ;;
    : )
        printf "Option -%s needs an argument.\n" "$OPTARG" >&2
        show_help
        echo ""
        exit 1
  esac
done
