

#cloud-config


write_files:
- content: |
    # bash config written by terraform and cloud init
    export CONTRADB_DOMAIN=${contradb_domain_fetcher}
  path: /home/rails/provisioned_env.d/contradb-domain
  permissions: '0755'

runcmd:
 - chown -R rails.rails /home/rails/provisioned_env.d/
 - echo "for f in ~/provisioned_env.d/*; do . \$f ; done" >> /home/rails/.bashrc
 # TODO: checkout & pull the current branch to make sure we're up-to-date, so we can use amis
 # - sudo -u ubuntu git clone "https://github.com/contradb/contra.git" --branch terraform /home/ubuntu/contra
 # - mv /tmp/master.key /home/ubuntu/contra/config
 # - chown ubuntu.ubuntu /home/ubuntu/contra/config/master.key
 - /home/rails/contra/terraform/ec2-init.sh '${postgres_password}'
