#!/bin/bash

# Install OCI-CLI

wget -O ~ubuntu/ociinstall_wget.sh https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
chmod 755 ~ubuntu/ociinstall_wget.sh
~/ociinstall_wget.sh --accept-all-defaults

# Populate and setup OCI config file with tenancy ocid for use with instance_principal auth

mkdir /home/ubuntu/.oci
# TENANCY_ID=$(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.metadata.tenancy_id' | tr -d '"')
echo "[DEFAULT]" >> /home/ubuntu/.oci/config
echo "tenancy=${tenancy_id}" >> /home/ubuntu/.oci/config

chmod 600 /home/ubuntu/.oci/config

# Put Deployment ID in to ubuntu home directory

# DEPLOYMENT_ID=$(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.metadata.deployment_id' | tr -d '"')
echo "${deployment_id}" >> /home/ubuntu/deployment_id