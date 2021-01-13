#!/usr/bin/bash

BRANCH=$1

# runs as root in a random directory

set -e
set -x

sleep 30

adduser --no-create-home --system contradbd
addgroup rails
usermod -a -G rails ubuntu
usermod -a -G rails contradbd


# install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt-get update
# install without node, since we'll install that via asdf later
apt-get install -y --no-install-recommends yarn

# required for building ruby
apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev

# required for postgres (and also compilation of ruby?)
apt-get install -y postgresql postgresql-contrib libpq-dev

apt-get install -y nginx

# for puma pipe
sudo -u ubuntu -g rails mkdir -p /home/ubuntu/run/
sudo -u ubuntu -g rails chmod ug=rwx /home/ubuntu/run/

sudo -u ubuntu -g rails mkdir /home/ubuntu/provisioned_env.d/
sudo -u ubuntu -g rails touch /home/ubuntu/provisioned_env.d/noop # so that shell glob expansion finds something, and doesn't just lay an * egg
sudo -u ubuntu -g rails bash -c 'echo export PATH="\${PATH}:/home/ubuntu/contra/bin" > /home/ubuntu/provisioned_env.d/binstubs'

sudo -u ubuntu -g rails chmod -R go-w /home/ubuntu/provisioned_env.d/

# The first line of bashrc is before the interactive shell check kicks out non-interactive shells.
# ssh'ed scripts into the machine are neither interactive nor login, but they need to run this line
# so this is the only place to put this I see.
sudo -u ubuntu -g rails sed -i '1s|^|. provisioned_env.sh\n\n|' /home/ubuntu/.bashrc
sudo -u ubuntu -g rails bash -c "echo 'for f in /home/ubuntu/provisioned_env.d/*; do  . \$f ; done' > /home/ubuntu/provisioned_env.sh"
sudo -u ubuntu -g rails chmod 755 /home/ubuntu/provisioned_env.sh

sudo -u ubuntu -g rails git clone 'https://github.com/contradb/contra.git' --branch $BRANCH /home/ubuntu/contra
sudo -u ubuntu -g rails chmod -R go-w /home/ubuntu/contra
mv /home/ubuntu/master.key /home/ubuntu/contra/config/master.key
chmod 600 /home/ubuntu/contra/config/master.key

sudo -u ubuntu -g rails git config --global advice.detachedHead false # rubybuild plugin, part of asdf, otherwise vomits on packer build log

sudo -s -u ubuntu -g rails /home/ubuntu/contra/terraform/ec2-init.d/asdf
sudo -s -u ubuntu -g rails /home/ubuntu/contra/terraform/ec2-init.d/gems

sudo -u ubuntu -g rails git config --global advice.detachedHead true # restore default
