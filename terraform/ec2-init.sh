#!/usr/bin/bash

# Hi! I'm the script that runs on a freshly minted ec2 ubuntu 20.04 instance

# crash if any command fails
set -e

# yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt-get update
# install without node, since we'll install that via asdf later
apt-get install -y --no-install-recommends yarn

# postgres
apt-get install -y postgresql postgresql-contrib libpq-dev

# git clone contradb
# TODO clone the default branch instead of the terraform branch
sudo -u ubuntu git clone https://github.com/contradb/contra.git --branch terraform

# done with root stuff?
cd ~ubuntu/contra

# TODO Loop over stuff in init-ec2.d/ directory and run it as user ubuntu
# but for now
sudo -u ubuntu ec2-init.d/asdf
sudo -u ubuntu ec2-init.d/gems

