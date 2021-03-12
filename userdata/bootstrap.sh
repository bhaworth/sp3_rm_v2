#!/bin/bash

p /etc/motd /etc/motd.bkp
cat << EOF > /etc/motd
 
I have been modified by cloud-init at $(date)
Ben Haworth
EOF

# Partition and Format Block Volumes

echo 'type=83' | sudo sfdisk /dev/oracleoci/oraclevdb
echo 'type=83' | sudo sfdisk /dev/oracleoci/oraclevdc

sudo mkfs -t ext3 /dev/oracleoci/oraclevdb1
sudo mkfs -t ext3 /dev/oracleoci/oraclevdc1

# Mount the volumes

sudo mkdir /data /work

sudo mount /dev/oracleoci/oraclevdb1 /data
sudo mount /dev/oracleoci/oraclevdc1 /work

# Install OCI-CLI

