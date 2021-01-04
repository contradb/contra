

#cloud-config


write_files:
- content: |
    # bash config written by terraform and cloud init
    export CONTRADB_DOMAIN=${contradb_domain_fetcher}
  path: /tmp/skel/provisioned_env.d/contradb-domain
  permissions: '0755'
# because write_files fires before user creation, and will create files as root,
# we can't create anything in /home/ubuntu yet. We create it in /tmp/skel now
# and copy it below.
# - content: ${rails_master_key}
#   path: /tmp/master.key
#   permissions: '0600'

# run commands
# default: none
# runcmd contains a list of either lists or a string
# each item will be executed in order at rc.local like level with
# output to the console
# - runcmd only runs during the first boot
# - if the item is a list, the items will be properly executed as if
#   passed to execve(3) (with the first arg as the command).
# - if the item is a string, it will be simply written to the file and
#   will be interpreted by 'sh'
#
# Note, that the list has to be proper yaml, so you have to quote
# any characters yaml would eat (':' can be problematic)
runcmd:
 # - chown -R ubuntu.ubuntu /tmp/skel
 - find /tmp/skel -type d -exec chmod 770 {} \;
 - cp -R --preserve mode,ownership /tmp/skel/* /home/ubuntu/
 - echo "for f in ~/provisioned_env.d/*; do . \$f ; done" >> /home/ubuntu/.bashrc
 # TODO: checkout & pull the current branch to make sure we're up-to-date, so we can use amis
 # - sudo -u ubuntu git clone "https://github.com/contradb/contra.git" --branch terraform /home/ubuntu/contra
 # - mv /tmp/master.key /home/ubuntu/contra/config
 # - chown ubuntu.ubuntu /home/ubuntu/contra/config/master.key
 - /home/ubuntu/contra/terraform/ec2-init.sh '${postgres_password}'
 
 # - [ ls, -l, / ]
 # - [ sh, -xc, "echo $(date) ': hello world!'" ]
 # - [ sh, -c, echo "=========hello world'=========" ]
 # - ls -l /root
 # # Note: Don't write files to /tmp from cloud-init use /run/somedir instead.
 # # Early boot environments can race systemd-tmpfiles-clean LP: #1707222.
 # - mkdir /run/mydir
 # - [ wget, "http://slashdot.org", -O, /run/mydir/index.html ]
