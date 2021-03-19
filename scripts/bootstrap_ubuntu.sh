#!/bin/bash

# Install OCI-CLI

sudo -H -u ubuntu wget -O ~ubuntu/ociinstall_wget.sh https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
sudo -H -u ubuntu chmod 755 ~ubuntu/ociinstall_wget.sh
sudo -H -u ubuntu ~ubuntu/ociinstall_wget.sh --accept-all-defaults

# Populate and setup OCI config file with tenancy ocid for use with instance_principal auth

sudo -H -u ubuntu mkdir /home/ubuntu/.oci
sudo -H -u ubuntu touch /home/ubuntu/.oci/config
TENANCY_ID=$(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.metadata.tenancy_id' | tr -d '"')
echo "[DEFAULT]" >> /home/ubuntu/.oci/config
echo "tenancy=${TENANCY_ID}" >> /home/ubuntu/.oci/config

chmod 600 /home/ubuntu/.oci/config

# Put Deployment ID in to ubuntu home directory

sudo -H -u ubuntu touch /home/ubuntu/deployment_id
DEPLOYMENT_ID=$(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.metadata.deployment_id' | tr -d '"')
echo "${DEPLOYMENT_ID}" >> /home/ubuntu/deployment_id

# Pull the Private Key for GitLab access

sudo -i -H -u ubuntu oci secrets secret-bundle get \
 --raw-output \
 --auth instance_principal \
 --secret-id ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdia3ejrsbqkv6iz2ipwngjmteeduitufuu7u35sgxrx7wna \
 --query "data.\"secret-bundle-content\".content" | base64 --decode > /home/ubuntu/.ssh/gitlab_key

chown ubuntu:ubuntu /home/ubuntu/.ssh/gitlab_key
chmod 600 /home/ubuntu/.ssh/gitlab_key

# Clone Git Library using Private Key from OCI Secrets Service

sudo -i -H -u ubuntu GIT_SSH_COMMAND='ssh -i /home/ubuntu/.ssh/gitlab_key -o StrictHostKeyChecking=no' git clone git@gitlab.com:MMMCloudPipeline/sp3.git

# sudo -H -u ubuntu bash /home/ubuntu/sp3/sp3docs/install-basic.bash
# sudo -H -u ubuntu bash /home/ubuntu/sp3/sp3docs/install-oci.sh