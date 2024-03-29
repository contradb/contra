variable "domain_name" {
  default     = null
  type        = string
  description = <<EOF
Leave null for no domain. 
The domain name to configure to point to the server, e.g. 'contradb.com'.
Note that for any domain sent through here to actually have authority,
a human has to go into the registrar's configuration and point the nameservers 
to the name_servers outputs. 
EOF
}

variable "branch" {
  description = "git branch"
  type        = string
  default     = "master"
}

variable "environment_tag" {
  description = <<EOF
  Tag applied to aws resources, e.g. 'staging' or 'production'. 
  'production' is not actually currently used in production, 
  because production predates the option.

  This has no effect on how rails or linux behave, and is not visible to them.
  EOF
  type        = string
  default     = "dev"
}

variable "ssh_public_key_title" {
  default = "contradb-terraform-key"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/contradb-terraform.pub"
}

variable "ssh_private_key_path" {
  default = "~/.ssh/contradb-terraform"
}

variable "database_path" {
  type        = string
  default     = null
  description = <<EOF
path to the .sql file to initialize the instance to. By default looks
at the highest file of the form
~/priv/contradb/contradb-2021-12-34.sql" because that's where the
contradb-backup program stores its nightlies.
EOF
}

variable "database_archive_dir" {
  type        = string
  default     = null
  description = <<EOF
If database_path isn't used, then database_archive_dir specifies where
to look for database images and pick the newest based on the
filenames.
"~/priv/contradb" is the default.
EOF
}

