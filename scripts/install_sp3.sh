#!/bin/bash

set -x

# Pull the Private Key for GitLab access

oci secrets secret-bundle get \
 --raw-output \
 --auth instance_principal \
 --secret-id ${Sp3_gitrepo_secret_id} \
 --query "data.\"secret-bundle-content\".content" | base64 --decode > /home/ubuntu/.ssh/gitlab_key

chmod 600 /home/ubuntu/.ssh/gitlab_key

# Clone Git Library using Private Key from OCI Secrets Service

echo "---Cloning SP3 Git"
GIT_SSH_COMMAND='ssh -i /home/ubuntu/.ssh/gitlab_key -o StrictHostKeyChecking=no' git clone git@gitlab.com:MMMCloudPipeline/sp3.git

# Create key pair for SSH to self

ssh-keygen -t rsa -f /home/ubuntu/.ssh/self_id_rsa -q -P ""
cat /home/ubuntu/.ssh/self_id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys

# Run first sp3 install script
echo "---Running /home/ubuntu/sp3/sp3doc/install-basic.bash"
ssh -i /home/ubuntu/.ssh/self_id_rsa -o StrictHostKeyChecking=no ubuntu@localhost bash /home/ubuntu/sp3/sp3doc/install-basic.bash
echo "---Finished /home/ubuntu/sp3/sp3doc/install-basic.bash"

# Get pipelines from Object Storage
echo "---Downloading pipelines from object storage"

oci os object bulk-download -bn artic_images --download-dir /tmp --overwrite --auth instance_principal

# Move pipeline images to /data

sudo mv /tmp/*.sif /data/images/
sudo mv /tmp/*.simg /data/images/
sudo mv /tmp/*.img /data/images/
sudo chown root:root /data/images/*.sif
sudo chown root:root /data/images/*.simg
sudo chown root:root /data/images/*.img

# Get kraken DB

sudo mkdir -p /data/databases/kraken2
sudo tar -xavf /tmp/minikraken2_v2_8GB_201904.tgz -C /data/databases/kraken2
sudo chown -R root:root /data/databases/kraken2/*
sudo rm /tmp/minikraken2_v2_8GB_201904.tgz

# Create samples directory

sudo mkdir /data/inputs/uploads/oxforduni

# Get 48 sample data from Object Storage
echo "---Downloading 48 samples from object storage"
sudo mkdir /data/inputs/uploads/oxforduni/210204_M01746_0015_000000000-JHB5M
sudo chown ubuntu:ubuntu /data/inputs/uploads/oxforduni/210204_M01746_0015_000000000-JHB5M
oci os object bulk-download -bn 48_samples --download-dir /data/inputs/uploads/oxforduni/210204_M01746_0015_000000000-JHB5M --overwrite --auth instance_principal
sudo chown -R root:root /data/inputs/uploads/oxforduni/210204_M01746_0015_000000000-JHB5M

# Get / extract 1000 samples from Object Storage
if ${Sp3_deploy_1k}
then
    echo "---Sp3_deploy_1k was ${Sp3_deploy_1k}.... downloading 1000 samples from object storage"
    sudo mkdir /data/inputs/uploads/oxforduni/2021-04-06-1000_samples
    sudo chown ubuntu:ubuntu /data/inputs/uploads/oxforduni/2021-04-06-1000_samples
    oci os object bulk-download -bn 1000_samples --download-dir /data/inputs/uploads/oxforduni/2021-04-06-1000_samples --overwrite --auth instance_principal
    sudo chown -R root:root /data/inputs/uploads/oxforduni/2021-04-06-1000_samples
fi

# Deploy script to download and extract 1000 samples post build, if required (user initiated)

tee <<EOF /home/ubuntu/deploy_1k_samples.sh
#!/bin/bash

# Use this script to download and extract the 1000 samples stored in Object Storage
# if you did not do this during the initial head node build process

echo "---Downloading 1000 samples from object storage"
sudo mkdir /data/inputs/uploads/oxforduni/2021-04-06-1000_samples
sudo chown ubuntu:ubuntu /data/inputs/uploads/oxforduni/2021-04-06-1000_samples
oci os object bulk-download -bn 1000_samples --download-dir /data/inputs/uploads/oxforduni/2021-04-06-1000_samples --overwrite --auth instance_principal
sudo chown -R root:root /data/inputs/uploads/oxforduni/2021-04-06-1000_samples
EOF

chmod 755 /home/ubuntu/deploy_1k_samples.sh

# Run second sp3 install script
echo "---Running /home/ubuntu/sp3/sp3doc/install-oci.sh"
ssh -i /home/ubuntu/.ssh/self_id_rsa -o StrictHostKeyChecking=no ubuntu@localhost bash /home/ubuntu/sp3/sp3doc/install-oci.sh
echo "---Finished /home/ubuntu/sp3/sp3doc/install-oci.sh"

