variable "ssh_public_key_path" {
  default = "~/.ssh/contradb-terraform.pub"
}

variable "ssh_private_key_path" {
  default = "~/.ssh/contradb-terraform"
}

variable "database_path" {
  type = string
  description = "path to .sql file for initializing the database on the new server"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "server" {
  # ami = data.aws_ami.ubuntu.id
  ami = "ami-0cadefbce6cf35925"
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

data "template_file" "nginx_site_config" {
  template = file("${path.module}/nginx.tpl")
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
    source = var.database_path
    destination = "/home/ubuntu/db.sql"
  }
  provisioner "file" {
    destination = "/home/ubuntu/rails-env.d/contradb-domain"
    content = "export CONTRADB_DOMAIN=$${CONTRADB_DOMAIN:-${null == var.domain_name ? "`curl --max-time 5 --silent http://169.254.169.254/latest/meta-data/public-hostname`" : var.domain_name}}"
  }
  provisioner "file" {
    content = data.template_file.nginx_site_config.rendered
    destination = "/home/ubuntu/etc-nginx-sites-avaiable-contradb" # "/etc/nginx/sites-available/contradb"
  }
  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo -u postgres psql -c "CREATE USER contradbd WITH CREATEDB PASSWORD '${random_password.postgres.result}';"
sudo -u postgres psql -c "CREATE USER ubuntu WITH CREATEDB PASSWORD '${random_password.postgres.result}';"
EOF
      ,
      "sudo rm /etc/nginx/sites-enabled/default",
      "sudo cp /home/ubuntu/etc-nginx-sites-avaiable-contradb /etc/nginx/sites-available/contradb",
      "sudo ln -s /etc/nginx/sites-available/contradb /etc/nginx/sites-enabled/contradb",
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


