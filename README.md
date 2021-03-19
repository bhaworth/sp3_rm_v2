# SP3 Bootstrap Resource Manager Stack
The Terraform and Shell scripts within this repository facilitate the build out of an SP3 cluster using OCI Resource Manager.

## Resource Manager Files
The `schema.yaml` file defines the Variable Input/Capture screen within the Resource Manager stack.  It is used to allow dropdown selection of compartments, shapes, ADs and so on.  It also applies verification of inputs and optional variables to be set. 

Upon completion of the deployment, an Application Information tab will be shown within the Stack.  The Public IP of the Bastion as well as the Private IP of the Head Node will be displayed here.  The deployment ID will also be shown - this is included in almost all resource names and is a random 5 character lower case string to help people identify differing stack deployments, beyond the optional environment name and user defined name prefix.
## Terraform Files

- `vcn.tf` creates the Virtual Cloud network with CIDR 10.0/16, a public subnet (10.0.0.0/24) with route table and security list with an Internet Gateway and a private subnet (10.0.1.0/24) with route table and security list with a NAT Gateway.
- `main.tf` creates the Compute Instances and Storage Volumes.  A Bastion server is connected to the Public Subnet and a Head Node server for the SP3 Cluster is attached to the Private Network.  The Head Node has two balanced tier Block Volumes attached via para-virtualisation.
- `lbaas.tf` creates the Load Balancer service.
- `lb_nsg.tf` creates the Network Security Group for the Load Balancer
- `hn_nsg.tf` creates the Network Security Group for the Head Node
- `datasources.tf` is used for specific functions and data sources within Terraform
- `iam.tf` creates a dynamic group and policy to allow OCI CLI operations from the Head Node


## User Data Files
The shell scripts within the the `userdata` directory are used to configure the Head Node Compute Instance once it has booted for the first time.

`bootstrap.sh` is the file used normally.  It performs the following activities:
- Installs jq for JSON query
- Partitions, formats (with ext3) the two Block Volumes
- Mounts the Block Volumes to /data and /work
- Installs the OCI CLI under the ubuntu user together with a .oci/profile file suited for using instance_principal authentication
- Modifies ubuntu .bashrc to export OCI_CLI_AUTH=instance_principal
- Installs NFS Server
- Configures NFS service ports to static mappings
- Adds the NFS ports as well as TCP/80 to iptables
- Pulls GitLab Private SSH Key from OCI Secrets service
- Clones SP3 GitLab Repo

`bootstrap_test.sh` does the same as `bootstrap.sh` plus 
- exports /data and /work for NFS testing
- installs the NGINX web service (for testing load balancer configurations).