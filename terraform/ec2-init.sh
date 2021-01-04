#!/usr/bin/bash

# Hi! I'm the script that runs on a freshly minted ec2 ubuntu 20.04 instance
# I take an argument:

POSTGRES_PASSWORD=$1

# log all these commands
set -x

# crash if any command fails
set -e

cd ~rails/contra


# postgres
apt-get install -y postgresql postgresql-contrib libpq-dev
sudo -u postgres psql -c "CREATE USER rails WITH CREATEDB PASSWORD '$POSTGRES_PASSWORD';"

# asdf and gems are moving to packer build time
# sudo -u rails terraform/ec2-init.d/asdf
# sudo -s -u rails terraform/ec2-init.d/gems
# rails is staying here because we need the postgres password
sudo -u rails terraform/ec2-init.d/rails $POSTGRES_PASSWORD
