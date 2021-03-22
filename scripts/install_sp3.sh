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

GIT_SSH_COMMAND='ssh -i /home/ubuntu/.ssh/gitlab_key -o StrictHostKeyChecking=no' git clone git@gitlab.com:MMMCloudPipeline/sp3.git

ssh-keygen -t rsa -f /home/ubuntu/.ssh/self_id_rsa -q -P ""
cat /home/ubuntu/.ssh/self_id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
sed -i '13s/.*/cd \/home\/ubuntu\/sp3/' /home/ubuntu/sp3/sp3doc/install-basic.bash
ssh -i /home/ubuntu/.ssh/self_id_rsa -o StrictHostKeyChecking=no ubuntu@localhost bash /home/ubuntu/sp3/sp3doc/install-basic.bash
ssh -i /home/ubuntu/.ssh/self_id_rsa -o StrictHostKeyChecking=no ubuntu@localhost bash /home/ubuntu/sp3/sp3doc/install-oci.sh

# Get data from Object Storage

sudo mkdir -p /data/inputs/users/oxforduni/

oci os object get -bn artic_images --name artic-ncov2019-illumina.sif --file /data/images/artic-ncov2019-illumina.sif
oci os object get -bn artic_images --name artic-ncov2019-nanopore.sif --file /data/images/artic-ncov2019-nanopore.sif
oci os object get -bn upload_samples --name 210204_M01746_0015_000000000-JHB5M.tar --file /tmp/210204_M01746_0015_000000000-JHB5M.tar

# Extract sample data

nohup sudo tar -xf /tmp/210204_M01746_0015_000000000-JHB5M.tar --directory /data/inputs/users/oxforduni/ && rm /tmp/210204_M01746_0015_000000000-JHB5M.tar &
