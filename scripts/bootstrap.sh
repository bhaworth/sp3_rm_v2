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

# Install jq

apt install -y jq

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
TENANCY_ID=$(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.metadata.tenancy_id' | tr -d '"')
echo "[DEFAULT]" >> /home/ubuntu/.oci/config
echo "tenancy=${TENANCY_ID}" >> /home/ubuntu/.oci/config

chmod 600 /home/ubuntu/.oci/config

# Put Deployment ID in to ubuntu home directory

sudo -H -u ubuntu touch /home/ubuntu/deployment_id
DEPLOYMENT_ID=$(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.metadata.deployment_id' | tr -d '"')
echo "${DEPLOYMENT_ID}" >> /home/ubuntu/deployment_id

# Install NFS Server

apt-get install nfs-server -y

# Edit exports file
# echo '/work     10.0.0.0/23(rw,no_root_squash)' >> /etc/exports
# echo '/data     10.0.0.0/23(rw,no_root_squash)' >> /etc/exports

# Set mountd and nlockmgr port numbers

cp /etc/default/nfs-kernel-server /etc/default/nfs-kernel-server.orig
sed -i 's/RPCMOUNTDOPTS="--manage-gids"/RPCMOUNTDOPTS="--manage-gids -p 2000"/g' /etc/default/nfs-kernel-server

cat << EOF > /etc/sysctl.d/30-nfs-ports.conf
fs.nfs.nlm_tcpport = 2001
fs.nfs.nlm_udpport = 2002
EOF

sysctl --system
systemctl restart nfs-server.service

# Add NFS to iptables

iptables -I INPUT 6 -s 10.0.0.0/16 -p tcp -m multiport --ports 111,2000,2001,2049 -j ACCEPT
iptables -I INPUT 7 -s 10.0.0.0/16 -p udp -m multiport --ports 111,2000,2002,2049 -j ACCEPT
iptables -I INPUT 8 -s 10.0.0.0/16 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

# Pull the Private Key for GitLab access

sudo -i -H -u ubuntu oci secrets secret-bundle get \
 --raw-output \
 --auth instance_principal \
 --secret-id ocid1.vaultsecret.oc1.uk-london-1.amaaaaaahe4ejdia3ejrsbqkv6iz2ipwngjmteeduitufuu7u35sgxrx7wna \
 --query "data.\"secret-bundle-content\".content" | base64 --decode > /home/ubuntu/.ssh/gitlab_key

chown ubuntu:ubuntu /home/ubuntu/.ssh/gitlab_key
chmod 600 /home/ubuntu/.ssh/gitlab_key

# FOR DEV WORK - Put Public SSH Keys in to instance

# cat << EOF >> /home/ubuntu/.ssh/authorized_keys 
# ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDSyajjG65ktATOZSrjWazWDocen5cGA3d80TOfhtsIPDJy/Vhz0gG/O/gIk/jNHDX+oGuMkKj3c3vtuSCho/cEhMX30HzyqQdeFChWypxc2MFPLS+wQjLdiELCgiLKZpEBYIROJXHfkQ7JwuhIu1pV9z2Or7QYDVEHUWw+Y5aH9xPxyNBQ6UQZzSxbGh15b7dd3ewrlpfWNQMRjym70tu5SDjd4vjSvWSES1oxlL/GhePSL7Ld6WTMXVyJWaEYsbRxFT2MImTnPENbaR931tk2oXlbzJulEiOvZWT8KfyzRi8xIpBGENcWjIjB6UWPAssvBX3ZANTET5VbYX37UdZr fowler@ceftaz.local
# ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCZGMSmW2CJP+GENQqHnGTMtOXtBLB/Hju9i8HV3nJWhozffiuKnuBl8nJxsHdazRYUWWHnaQ+ckBvac1MA3NJXAV7oZDEc7mFOhrRH2zboEG4GJhvct/brveDf/b3T651o1Nh1od2wWRRbsYmWprKKNhp80Q80KA13/PFlQA7g21weEDwrESeVeHUviVpvr/bRHgX7vSv0pWsPQuZjDt6LcPRGlL8JajNctq0dtao2eGfXtd591v986Xxiba1Tvj5VbtKe+F4bvfBnLZ+w58op3ZtChX70KYfTdXeKf4XVRrvEzh7NqGvcYBwfx3BRRn6R7LQ8pGyDL9mqh61XNzjX dennis@mmm-l8spare
# ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxp09SrS+Wht8yUIqgAq4gter3n9E/Lg+XqjTFE12DNYy5/k4Ne1nKNNlxfsBJ28e/NZQZcBKJdh/xVIyySjp8PYs8LOfWXvAqIcmrsgbPOw61B2XaEoXdLpMvPxH4KIs1bGi6UyhLl2+dMqjPhbzXatGvs/6yoq/znuMd4Dbeh+75cRXwIIVR/uUd6J0ezO8n8Ln1D1KamhDfuxrh6yUQWuRoLFFeZtRFLQhyOyGwn+sQZVoTmuhBIZuPnLJismrTvund/biUSnYycAEIUZ+xEc7hKpPVU/hSeaX2dfCRitcU9Pqq2HZAEYNsow2cC0HM1ZvGJ+mY0VCdWYpGBokH fan.uk@outlook.com
# EOF

# Clone Git Library using Private Key from OCI Secrets Service

sudo -i -H -u ubuntu GIT_SSH_COMMAND='ssh -i /home/ubuntu/.ssh/gitlab_key -o StrictHostKeyChecking=no' git clone git@gitlab.com:MMMCloudPipeline/sp3.git

# sudo -H -u ubuntu bash /home/ubuntu/sp3/sp3docs/install-basic.bash
# sudo -H -u ubuntu bash /home/ubuntu/sp3/sp3docs/install-oci.sh

# Install Nginx
# apt install nginx -y