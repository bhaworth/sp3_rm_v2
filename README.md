# SP3 Bootstrap Resource Manager Stack
The Terraform and Shell scripts within this repository facilitate the build out of an SP3 cluster using OCI Resource Manager.

## Resource Manager Files
The `schema.yaml` file defines the Variable Input/Capture screen within the Resource Manager stack.  It is used to allow dropdown selection of compartments, shapes, ADs and so on.  It also applies verification of inputs and optional variables to be set. The file also allows for capture of information for the worker nodes that the head node will build out.  These details are not used by Terraform other than to input in to the stack_info.json file that is injected in to the head node, together with other details about the stack.

The stack also gives the user the option to disable the default behaviour of creating a dedicated compartment for all resources within the deployment.  This compartment is created under the compartment selected within the stack config.  Other options include deploying a sample nginx HTTPS server with DNS name in oci.sp3dev.ml.

Upon completion of the deployment, an Application Information tab will be shown within the Stack.  The Public IP of the Bastion as well as the Private IP of the Head Node will be displayed here.  The deployment ID will also be shown - this is included in almost all resource names and is a random 5 character lower case string to help people identify differing stack deployments, beyond the optional environment name and user defined name prefix.
## Terraform Files

- `vcn.tf` creates the Virtual Cloud network with CIDR 10.0/16, a public subnet (10.0.0.0/24) with route table and security list with an Internet Gateway and a private subnet (10.0.1.0/24) with route table and security list with a NAT Gateway.
- `main.tf` creates the Compute Instances and Storage Volumes.  A Bastion server is connected to the Public Subnet and a Head Node server for the SP3 Cluster is attached to the Private Network.  The Head Node has two balanced tier Block Volumes attached via para-virtualisation.
- `lbaas.tf` creates the Load Balancer service with a TCP/443 pass through listener to the headnode as the lone backend server.
- `lb_nsg.tf` creates the Network Security Group for the Load Balancer
- `hn_nsg.tf` creates the Network Security Group for the Head Node
- `datasources.tf` is used for specific functions and data sources within Terraform
- `iam.tf` creates a dynamic group and policy to allow OCI CLI operations from the Head Node.  Optionally (default = true) creates a new compartment to house all the stack resources
- `dns.tf` creates an entry in the test domain oci.sp3dev.ml for the load balancer public IP

## Cloud Init Files
The `scripts` directory contains the scripts and configuration for Cloud Init.

`bastion_cloud-config.template.yaml` contains the instructions for Cloud Init on the Bastion
- write `/tmp/inject_pub_keys.sh`
- `write_files:` is performed before users are created, so first run chmod on ubuntu script so that user ubuntu can run the script
- run `bash /tmp/inject_pub_keys.sh` as ubuntu

`headnode_cloud-config.template.yaml` contains the instructions for Cloud Init on the Head Node
- write `/root/bootstrap_root.sh` and `/tmp/bootstrap_ubuntu.sh`, `/tmp/inject_pub_keys.sh`, `/tmp/stack_info.json`, `/tmp/install_sp3.sh`
- run `/root/bootstrap_root.sh`
- `write_files:` is performed before users are created, so first run chmod on scripts to run as user ubuntu
- run `bash /tmp/bootstrap_ubuntu.sh` as ubuntu
- run `mv /tmp/stack_info.json ~ubuntu/stack_info.json`
- run `bash /tmp/inject_pub_keys.sh` as ubuntu
- run `bash /tmp/install_sp3.sh` as ubuntu
- run `bash /tmp/install_nginx.sh` as ubuntu

`bootstrap_root.sh` is the file containing all the commands that run as root.
- Installs jq for JSON query
- Partitions, formats (with ext3) the two Block Volumes
- Mounts the Block Volumes to /data and /work
- Installs NFS Server
- Configures NFS service ports to static mappings
- Adds the NFS ports as well as TCP/80 to iptables

`bootstrap_ubuntu.sh` is the file containing all the commands that run as user ubuntu.  Some Terraform variables are injected in to this files as it is encoded in to the user data
- Installs the OCI CLI under the ubuntu user together with a .oci/profile file suited for using instance_principal authentication
- Modifies ubuntu .bashrc to export OCI_CLI_AUTH=instance_principal
- Writes the deployment_id file in ~ubuntu

`install_sp3.sh` - clones the Git repo for SP3 and begins the intialisation
- Pulls GitLab Private SSH Key from OCI Secrets service
- Clones SP3 GitLab Repo

`inject_pub_keys.sh` adds 4 public keys to ~ubuntu/.ssh/authorized_keys

`stack_info.json` Includes the following information:
- Deployment ID
- Head Node subnet OCID
- Load Balancer OCID
- Worker Node details captured in Stack Variables screen

`install_nginx.sh` will, if the option is selected in the stack, create a sample HTTPS nginx install and pull the wildcard certificate for .oci.sp3dev.ml from the OCI vault secret store