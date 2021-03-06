#!/usr/bin/bash

# This script needs to run after dns is set up
# Currently this is done manually, because
# We have to wait for some ape-person to go into the dns record and update it to point to the
# route 53 servers.

CERT_OWNER_EMAIL="$1"

CONTRADB_DOMAIN="$2"

if [ -z "$CERT_OWNER_EMAIL" ]
then
  1>&2 echo "expected required argument CERT_OWNER_EMAIL"
  exit 1
fi

if [ -z "$CONTRADB_DOMAIN" ]
then
  1>&2 echo "expected required argument CONTRADB_DOMAIN"
  exit 1
fi

set -x
set -e

sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
if [ ! -f /usr/bin/certbot ]; then
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
fi
sudo cp /etc/nginx/sites-available/contradb-no-ssl /etc/nginx/sites-available/contradb-no-ssl.bak
sudo certbot certonly -d "$CONTRADB_DOMAIN" -d "www.$CONTRADB_DOMAIN" --nginx -n -m "$CERT_OWNER_EMAIL" --agree-tos
sudo systemctl stop nginx
sudo rm /etc/nginx/sites-enabled/contradb
sudo ln -s /etc/nginx/sites-available/contradb-certbot /etc/nginx/sites-enabled/contradb
sudo systemctl start nginx

