# terraform plan -var-file=staging.tfvars -out=the.tfplan
environment_tag      = "staging"
ssh_public_key_title = "contradb-terraform-key-staging"
ssh_public_key_path  = "~/.ssh/contradb-terraform-staging.pub"
ssh_private_key_path = "~/.ssh/contradb-terraform-staging"
