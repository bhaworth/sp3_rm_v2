#!/bin/bash

if [[ ${install_nginx} ]]; then
    echo "Installing nginx..."
else
    echo "Exiting - nginx not to be installed"
    exit
fi


sudo apt install nginx -y

sudo mkdir -p /var/www/oci.sp3dev.ml/html
sudo chown -R ubuntu:ubuntu /var/www/oci.sp3dev.ml/html
sudo chmod 755 /var/www/oci.sp3dev.ml/html

cat << EOF | sudo tee -a /var/www/oci.sp3dev.ml/html/index.html
<html>
    <head>
        <title>Welcome to ${Sp3_env_name}.oci.sp3dev.ml!</title>
    </head>
    <body>
        <h1>Success!  The ${Sp3_env_name}.oci.sp3dev.ml server block is working!</h1>
    </body>
</html>
EOF

cat << EOF | sudo tee -a /etc/nginx/sites-available/oci.sp3dev.ml
server {
  listen 443 ssl;
  server_name *.oci.sp3dev.ml;

  ssl_certificate /etc/letsencrypt/live/oci.sp3dev.ml/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/oci.sp3dev.ml/privkey.pem;
  include /etc/letsencrypt/options-ssl-nginx.conf;
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

  root /var/www/oci.sp3dev.ml/html;
  index index.html;
  location / {
    try_files \$uri \$uri/ =404;
  }
}
EOF

sudo ln -s /etc/nginx/sites-available/oci.sp3dev.ml /etc/nginx/sites-enabled/

# Let's encrypt

sudo mkdir -p /etc/letsencrypt/live/oci.sp3dev.ml

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

# Pull the Let's Encrypt certificates for *.oci.sp3dev.ml from Vault

oci secrets secret-bundle get \
 --raw-output \
 --auth instance_principal \
 --secret-id ${Sp3dev_ml_ssl_secret_id} \
 --query "data.\"secret-bundle-content\".content" | base64 --decode > /home/ubuntu/.ssh/letsencrypt_fullchain.pem

oci secrets secret-bundle get \
 --raw-output \
 --auth instance_principal \
 --secret-id ${Sp3dev_ml_priv_secret_id} \
 --query "data.\"secret-bundle-content\".content" | base64 --decode > /home/ubuntu/.ssh/letsencrypt_privkey.pem

# Put Let's Encrypt certs in place
sudo cp /home/ubuntu/.ssh/letsencrypt_*.pem /etc/letsencrypt/live/oci.sp3dev.ml/
sudo chown root:root /etc/letsencrypt/live/oci.sp3dev.ml/*
sudo chmod 644 /etc/letsencrypt/live/oci.sp3dev.ml/*
sudo mv /etc/letsencrypt/live/oci.sp3dev.ml/letsencrypt_fullchain.pem /etc/letsencrypt/live/oci.sp3dev.ml/fullchain.pem
sudo mv /etc/letsencrypt/live/oci.sp3dev.ml/letsencrypt_privkey.pem /etc/letsencrypt/live/oci.sp3dev.ml/privkey.pem

sudo systemctl restart nginx.service