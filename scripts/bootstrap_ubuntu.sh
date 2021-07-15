#!/bin/bash

# Install OCI-CLI

wget -O ~ubuntu/ociinstall_wget.sh https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
chmod 755 ~ubuntu/ociinstall_wget.sh
~/ociinstall_wget.sh --accept-all-defaults

# Populate and setup OCI config file with tenancy ocid for use with instance_principal auth

mkdir /home/ubuntu/.oci
echo "[DEFAULT]" >> /home/ubuntu/.oci/config
echo "tenancy=${tenancy_id}" >> /home/ubuntu/.oci/config

chmod 600 /home/ubuntu/.oci/config

# pull WTSS container

docker login lhr.ocir.io -u lrbvkel2wjot/z_registry_ro -p `oci secrets secret-bundle get  --raw-output  --auth instance_principal  --secret-id ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdiahuoxfcywysr773dslkdssxqlm7lh7icww7uud4y3aqaa --query "data.\"secret-bundle-content\".content" | base64 --decode`

docker pull lhr.ocir.io/lrbvkel2wjot/wtss/wtss:latest