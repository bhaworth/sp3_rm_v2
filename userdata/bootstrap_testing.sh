#!/bin/bash

cp /etc/motd /etc/motd.bkp
cat << EOF > /etc/motd
 
I have been modified by cloud-init at $(date)

EOF

sleep 60

cp -p /home/ubuntu/.bashrc /home/ubuntu/.bashrc.bkp
cat << EOF >> /home/ubuntu/.bashrc
 
# Default OCI CLI to use Instance Principal authentication
export OCI_CLI_AUTH=instance_principal
EOF

apt update -y

# Partition and Format Block Volumes

echo 'type=83' | sfdisk /dev/oracleoci/oraclevdb
echo 'type=83' | sfdisk /dev/oracleoci/oraclevdc

sleep 10

mkfs -t ext3 /dev/oracleoci/oraclevdb1
mkfs -t ext3 /dev/oracleoci/oraclevdc1

# Mount the volumes

mkdir /data /work

mount /dev/oracleoci/oraclevdb1 /data
mount /dev/oracleoci/oraclevdc1 /work

# Install OCI-CLI

sudo -H -u ubuntu wget -O ~ubuntu/ociinstall_wget.sh https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
sudo -H -u ubuntu chmod 755 ~ubuntu/ociinstall_wget.sh
sudo -H -u ubuntu ~ubuntu/ociinstall_wget.sh --accept-all-defaults

# Populate and setup OCI config file with tenancy ocid for use with instance_principal auth

sudo -H -u ubuntu mkdir /home/ubuntu/.oci
sudo -H -u ubuntu touch /home/ubuntu/.oci/config
TENANCY_ID=$(curl -s http://169.254.169.254/opc/v1/instance/ | grep -o '"tenancy_id" : "[^"]*' | grep -o '[^"]*$')
echo "[DEFAULT]" >> /home/ubuntu/.oci/config
echo "tenancy=${TENANCY_ID}" >> /home/ubuntu/.oci/config

chmod 600 /home/ubuntu/.oci/config

# Put Deployment ID in to ubuntu home directory

sudo -H -u ubuntu touch /home/ubuntu/deployment_id
DEPLOYMENT_ID=$(curl -s http://169.254.169.254/opc/v1/instance/ | grep -o '"deployment_id" : "[^"]*' | grep -o '[^"]*$')
echo "${DEPLOYMENT_ID}" >> /home/ubuntu/deployment_id

# Install NFS Server

apt-get install nfs-server -y

# Edit exports file
echo '/work     10.0.0.0/23(rw,no_root_squash)' >> /etc/exports
echo '/data     10.0.0.0/23(rw,no_root_squash)' >> /etc/exports

# Set mountd and nlockmgr port numbers

cp /etc/default/nfs-kernel-server /etc/default/nfs-kernel-server.orig
sed -i 's/RPCMOUNTDOPTS="--manage-gids"/RPCMOUNTDOPTS="--manage-gids -p 2000"/g' /etc/default/nfs-kernel-server

cat << EOF > /etc/sysctl.d/30-nfs-ports.conf
fs.nfs.nlm_tcpport = 2001
fs.nfs.nlm_udpport = 2002
EOF

sysctl --system
systemctl restart nfs-server.service

# Add NFS and HTTP to iptables

iptables -I INPUT 6 -s 10.0.0.0/16 -p tcp -m multiport --ports 111,2000,2001,2049 -j ACCEPT
iptables -I INPUT 7 -s 10.0.0.0/16 -p udp -m multiport --ports 111,2000,2002,2049 -j ACCEPT
iptables -I INPUT 8 -s 10.0.0.0/16 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

# Install Nginx
apt install nginx -y
