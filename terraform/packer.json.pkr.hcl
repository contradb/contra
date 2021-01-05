variable "aws_access_key" {
  type    = string
  default = "${env("AWS_ACCESS_KEY_ID")}"
}

variable "aws_secret_key" {
  type    = string
  default = "${env("AWS_SECRET_ACCESS_KEY")}"
}

variable "aws_session_token" {
  type    = string
  default = "${env("AWS_SESSION_TOKEN")}"
}

variable "region" {
  type    = string
  default = "${env("AWS_DEFAULT_REGION")}"
}

variable "branch" {
  type    = string
  default = "terraform"
}

variable "database_path" {
  type =  string
  default = null
  description = <<EOF
path to the .sql file to initialize the instance to. By default looks
at the highest file of the form
~/priv/contradb/contradb-2021-12-34.sql" because that's where the
contradb-backup program stores its nightlies.
EOF
}

variable "sql_backup_dir" {
  type = string
  default = "/home/dm/priv/contradb"
}

# "timestamp" template function replacement
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")

  tmp_database_paths = fileset(var.sql_backup_dir, "contradb-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*.sql")
  database_path = null != var.database_path ? var.database_path : "${var.sql_backup_dir}/${element (sort(local.tmp_database_paths), length(local.tmp_database_paths) - 1)}"
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/from-1.5/blocks/source
source "amazon-ebs" "autogenerated_1" {
  access_key    = "${var.aws_access_key}"
  ami_name      = "packer-linux-aws-demo-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "${var.region}"
  secret_key    = "${var.aws_secret_key}"
  source_ami_filter {
    most_recent = true
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners = ["099720109477"]
  }
  ssh_username = "ubuntu"
  token        = "${var.aws_session_token}"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/from-1.5/blocks/build
build {
  sources = ["source.amazon-ebs.autogenerated_1"]

  provisioner "file" {
    destination = "/tmp/packer-init.sh"
    source      = "./packer-init.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo chown root.root /tmp/packer-init.sh",
      "sudo chmod u+x /tmp/packer-init.sh",
      "sudo /tmp/packer-init.sh ${var.branch}"
    ]
  }
}
