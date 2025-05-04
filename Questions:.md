Questions:

    * how do you run the deployment, terraform apply on the dir?
    * what OS release do you have in your hosts?
    * can I reduce the number of computes?
    * Defaults for `container-image-metadata-url` and `agent-metadata-url` since I do not host any of those?
    * why is ceph-osd commented out in 00-variables.tf?
    * the way placement is done atm balances computes and control plane across all asrocks, any reason why this is the case? I'm thinking on putting all computes on the same machine and only balance the control plane