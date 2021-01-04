#!/usr/bin/bash

BRANCH=$1

# runs as root in a random directory

set -e
set -x

# install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
# install without node, since we'll install that via asdf later
sudo apt-get install -y --no-install-recommends yarn

# add 'rails' user
sudo adduser --system --group rails
sudo -u rails mkdir /home/rails/provisioned_env.d/


sudo -u rails git clone 'https://github.com/contradb/contra.git' --branch $BRANCH /home/rails/contra

sudo -s -u rails /home/rails/contra/terraform/ec2-init.d/asdf
sudo -s -u rails /home/rails/contra/terraform/ec2-init.d/gems

