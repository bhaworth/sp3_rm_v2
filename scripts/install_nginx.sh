#!/bin/bash

if ${install_certs}; then
    echo "Installing certs..."
else
    echo "Exiting - certs not to be installed"
    exit
fi

# Let's encrypt

sudo mkdir -p /etc/letsencrypt/live/dev.gpas.world

cat << EOF | sudo tee -a /etc/letsencrypt/options-ssl-nginx.conf
# This file contains important security parameters. If you modify this file
# manually, Certbot will be unable to automatically provide future security
# updates. Instead, Certbot will print and log an error message with a path to
# the up-to-date file that you will need to refer to when manually updating
# this file.

ssl_session_cache shared:le_nginx_SSL:1m;
ssl_session_timeout 1440m;

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;

ssl_ciphers "ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS";
EOF

cat << EOF | sudo tee -a /etc/letsencrypt/ssl-dhparams.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA//////////+t+FRYortKmq/cViAnPTzx2LnFg84tNpWp4TZBFGQz
+8yTnc4kmz75fS/jY2MMddj2gbICrsRhetPfHtXV/WVhJDP1H18GbtCFY2VVPe0a
87VXE15/V8k1mE8McODmi3fipona8+/och3xWKE2rec1MKzKT0g6eXq8CrGCsyT7
YdEIqUuyyOP7uWrat2DX9GgdT0Kj3jlN9K5W7edjcrsZCwenyO4KbXCeAvzhzffi
7MA0BM0oNC9hkXL+nOmFg/+OTxIy7vKBg8P+OxtMb61zO7X8vC7CIAXFjvGDfRaD
ssbzSibBsu/6iGtCOGEoXJf//////////wIBAg==
-----END DH PARAMETERS-----
EOF

# Pull the Let's Encrypt certificates for *.dev.gpas.world from Vault

oci secrets secret-bundle get \
 --raw-output \
 --auth instance_principal \
 --secret-id ${Gpas_world_ssl_secret_id} \
 --query "data.\"secret-bundle-content\".content" | base64 --decode > /home/ubuntu/.ssh/letsencrypt_fullchain.pem

oci secrets secret-bundle get \
 --raw-output \
 --auth instance_principal \
 --secret-id ${Gpas_world_priv_secret_id} \
 --query "data.\"secret-bundle-content\".content" | base64 --decode > /home/ubuntu/.ssh/letsencrypt_privkey.pem

# Put Let's Encrypt certs in place
sudo cp /home/ubuntu/.ssh/letsencrypt_*.pem /etc/letsencrypt/live/dev.gpas.world/
sudo chown root:root /etc/letsencrypt/live/dev.gpas.world/*
sudo chmod 644 /etc/letsencrypt/live/dev.gpas.world/*
sudo mv /etc/letsencrypt/live/dev.gpas.world/letsencrypt_fullchain.pem /etc/letsencrypt/live/dev.gpas.world/fullchain.pem
sudo mv /etc/letsencrypt/live/dev.gpas.world/letsencrypt_privkey.pem /etc/letsencrypt/live/dev.gpas.world/privkey.pem

# sudo systemctl restart nginx.service