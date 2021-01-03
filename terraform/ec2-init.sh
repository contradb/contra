#!/usr/bin/bash

# Hi! I'm the script that runs on a freshly minted ec2 ubuntu 20.04 instance
# I take an argument:

POSTGRES_PASSWORD=$1

# log all these commands
set -x

# crash if any command fails
set -e

cd ~ubuntu/contra

# install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt-get update
# install without node, since we'll install that via asdf later
apt-get install -y --no-install-recommends yarn

# postgres
apt-get install -y postgresql postgresql-contrib libpq-dev
sudo -u postgres psql -c "CREATE USER ubuntu WITH CREATEDB PASSWORD '$POSTGRES_PASSWORD';"

# TODO Loop over stuff in init-ec2.d/ directory and run it as user ubuntu
# but for now
sudo -u ubuntu terraform/ec2-init.d/asdf
sudo -s -u ubuntu terraform/ec2-init.d/gems
sudo -u ubuntu terraform/ec2-init.d/rails $POSTGRES_PASSWORD
