# Documeent on these scripts

## Arif's lab specific

`fix_cloud_focal.sh`
`fix_cloud.sh`

## Generic scripts

`check_juju.sh`

Does a `juju status` anc discards active, idle units htat are green

`check_mongo.sh`

logs into a juju controller directly onto mongodb, below are the 2 arguments that will be taken

1. machine-id (0)
1. model-name (controller)

`check_queues.sh`

checks to see if the queues are balanced on all juju controllers.

	`check_vip_issue_db.sh`
debug-relations.sh
get_all_ips.sh
get_all_relation_info.sh
get_charm_versions.sh
get_details.sh
get_passwords.sh
get_relation_info.py
grab_vips.sh
reset.sh
test_juju.py
vault_init.sh
vault.sh

