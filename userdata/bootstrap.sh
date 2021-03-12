#!/bin/bash

p /etc/motd /etc/motd.bkp
cat << EOF > /etc/motd
 
I have been modified by cloud-init at $(date)
Ben Haworth
EOF

sudo apt update -y

# Install OCI-CLI

sudo su - ubuntu
wget -O ociinstall_wget.sh https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
chmod 755 ociinstall_wget.sh
./ociinstall.sh --accept-all-defaults
exit

# Install NFS Server

sudo apt-get install nfs-server -y

# Add NFS to iptables

####### TODO

# Partition and Format Block Volumes
# No Sleep before this assuming CLI install and NFS take > 30s.
# PV Block vols are not available immediately

echo 'type=83' | sudo sfdisk /dev/oracleoci/oraclevdb >> /tmp/bootstrap.log
echo 'type=83' | sudo sfdisk /dev/oracleoci/oraclevdc >> /tmp/bootstrap.log

sudo mkfs -t ext3 /dev/oracleoci/oraclevdb1 >> /tmp/boostrap.log
sudo mkfs -t ext3 /dev/oracleoci/oraclevdc1 >> /tmp/boostrap.log

# Mount the volumes

sudo mkdir /data /work

sudo mount /dev/oracleoci/oraclevdb1 /data
sudo mount /dev/oracleoci/oraclevdc1 /work



