variable "ssh_public_key_path" {
  default = "~/.ssh/contradb-terraform.pub"
}

variable "ssh_private_key_path" {
  default = "~/.ssh/contradb-terraform"
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

variable "database_archive_dir" {
  type = string
  default = null
  description = <<EOF
If database_path isn't used, then database_archive_dir specifies where
to look for database images and pick the newest based on the
filenames.
"~/priv/contradb" is the default.
EOF
}


data "external" "packer_ami_id" {
  program = ["${path.module}/packer-ami-id"]
}


locals {
  database_archive_dir = null == var.database_archive_dir ? pathexpand("~/priv/contradb") : var.database_archive_dir
  tmp_database_paths = fileset(local.database_archive_dir, "contradb-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*.sql")
  database_path = null != var.database_path ? var.database_path : "${local.database_archive_dir}/${element (sort(local.tmp_database_paths), length(local.tmp_database_paths) - 1)}"
  ami_id = data.external.packer_ami_id.result.ami_id
}

resource "aws_instance" "server" {
  ami = local.ami_id
  instance_type = "t2.micro"
  key_name = aws_key_pair.contra_key.key_name
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_web.id,
    aws_security_group.allow_outbound.id,
  ]
  subnet_id = aws_subnet.web.id

  tags = {
    Name = "contradb"
  }

  # delete_on_termination = eventually false, but for now true is aok
}

data "template_file" "nginx_site_config_no_ssl" {
  template = file("${path.module}/nginx-no-ssl.tpl")
  vars = {
    domain_name = null == var.domain_name ? "" : var.domain_name
  }
}

data "template_file" "nginx_site_config_certbot" {
  template = file("${path.module}/nginx-certbot.tpl")
  vars = {
    domain_name = null == var.domain_name ? "" : var.domain_name
  }
}

resource "null_resource" "server" {
  triggers = {
    server = aws_instance.server.id
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file(var.ssh_private_key_path)
    host = aws_eip.web_ip.public_dns
  }
  provisioner "file" {
    source = local.database_path
    destination = "/home/ubuntu/db.sql"
  }
  provisioner "file" {
    destination = "/home/ubuntu/rails-env.d/contradb-domain"
    content = "export CONTRADB_DOMAIN=$${CONTRADB_DOMAIN:-${null == var.domain_name ? "`curl --max-time 5 --silent http://169.254.169.254/latest/meta-data/public-hostname`" : var.domain_name}}"
  }
  provisioner "file" {
    content = data.template_file.nginx_site_config_no_ssl.rendered
    destination = "/home/ubuntu/etc-nginx-sites-avaiable-contradb-no-ssl"
  }
  provisioner "file" {
    content = data.template_file.nginx_site_config_certbot.rendered
    destination = "/home/ubuntu/etc-nginx-sites-avaiable-contradb-certbot"
  }
  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo -u postgres psql -c "CREATE USER contradbd WITH CREATEDB PASSWORD '${random_password.postgres.result}';"
sudo -u postgres psql -c "CREATE USER ubuntu WITH CREATEDB PASSWORD '${random_password.postgres.result}';"
EOF
      ,
      "sudo rm /etc/nginx/sites-enabled/default",
      "sudo cp /home/ubuntu/etc-nginx-sites-avaiable-contradb-no-ssl /etc/nginx/sites-available/contradb-no-ssl",
      "sudo cp /home/ubuntu/etc-nginx-sites-avaiable-contradb-certbot /etc/nginx/sites-available/contradb-certbot",
      "sudo ln -s /etc/nginx/sites-available/contradb-no-ssl /etc/nginx/sites-enabled/contradb",
      "sudo systemctl reload nginx",
      "umask 022 && cd /home/ubuntu/contra && git pull --no-edit",
      "sudo -g rails /home/ubuntu/contra/terraform/provisioning/rails ${random_password.postgres.result}",
      "sudo -u postgres psql contraprod -c 'GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO contradbd; GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO contradbd;'",
      "sudo install --mode 644 /home/ubuntu/contra/terraform/puma.service /etc/systemd/system/puma.service",
      "sudo systemctl enable puma",
      "sudo systemctl start puma",
    ]
  }
}

resource "aws_key_pair" "contra_key" {
  key_name   = "contradb-terraform-key"
  public_key = file(var.ssh_public_key_path)
  tags = {
    Name = "contradb"
  }
}

resource "aws_security_group" "allow_ssh" {
   name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id = aws_vpc.contra_vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "contradb"
  }
}

resource "aws_security_group" "allow_web" {
   name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id = aws_vpc.contra_vpc.id

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "contradb"
  }
}

resource "aws_security_group" "allow_outbound" {
   name        = "allow_outbound"
  description = "Allow all outbound traffic"
  vpc_id = aws_vpc.contra_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "contradb"
  }
}

resource "random_password" "postgres" {
  length = 26
  special = false
}

output "ip" {
  value = aws_eip.web_ip.public_ip
}

output "domain" {
  value = aws_eip.web_ip.public_dns
}


