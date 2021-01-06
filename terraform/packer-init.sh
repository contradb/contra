#!/usr/bin/bash

BRANCH=$1

# runs as root in a random directory

set -e
set -x

sleep 30


# install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
# install without node, since we'll install that via asdf later
sudo apt-get install -y --no-install-recommends yarn


# wait for cloud-init to set more sane apt environment
# note that this doesn't actually work, it always falls through immediately, hence the sleep 30 above
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 1; done'

# required for building ruby
sudo apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev

# required for postgres (and also compilation of ruby?)
apt-get install -y postgresql postgresql-contrib libpq-dev


sudo -u ubuntu mkdir /home/ubuntu/provisioned_env.d/
sudo -u ubuntu touch /home/ubuntu/provisioned_env.d/noop # so that shell glob expansion finds something, and doesn't just lay an * egg

# The first line of bashrc is before the interactive shell check kicks out non-interactive shells.
# ssh'ed scripts into the machine are neither interactive nor login, but they need to run this line
# so this is the only place to put this I see.
sudo -u ubuntu sed -i '1s|^|for f in ~/provisioned_env.d/*; do\n  . $f\ndone\n|' /home/ubuntu/.bashrc

sudo -u ubuntu git clone 'https://github.com/contradb/contra.git' --branch $BRANCH /home/ubuntu/contra

sudo -u ubuntu git config --global advice.detachedHead false # rubybuild plugin, part of asdf, otherwise vomits on packer build log

sudo -s -u ubuntu /home/ubuntu/contra/terraform/ec2-init.d/asdf
sudo -s -u ubuntu /home/ubuntu/contra/terraform/ec2-init.d/gems

sudo -u ubuntu git config --global advice.detachedHead true # restore default
