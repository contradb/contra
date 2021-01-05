variable "ssh_public_key_path" {
  default = "~/.ssh/contradb-terraform.pub"
}

variable "ssh_private_key_path" {
  default = "~/.ssh/contradb-terraform"
}

variable "rails_master_key_path" {
  default = "../config/master.key"
  type = string
  description = <<EOF
Rails master key, used for decrypting secrets. Typically stored in
$RAILS_ROOT/config/master.key. Shared among contradb team members.
EOF
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
  ami = "ami-0f0630b83c69a8a37"
  instance_type = "t2.micro"
  key_name = aws_key_pair.contra_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id = aws_subnet.web.id

  tags = {
    Name = "contradb"
  }

  # delete_on_termination = eventually false, but for now true is aok
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
    destination = "/home/ubuntu/provisioned_env.d/contradb-domain"
    content = "export CONTRADB_DOMAIN=${null == var.domain_name ? "`curl --max-time 5 --silent http://169.254.169.254/latest/meta-data/public-hostname`" : var.domain_name}"
  }
  provisioner "file" {
    source = var.rails_master_key_path
    destination = "/home/ubuntu/contra/config/master.key"
  }
  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo -u postgres psql -c "CREATE USER ubuntu WITH CREATEDB PASSWORD '${random_password.postgres.result}';"
EOF
      ,
      "~ubuntu/contra/terraform/ec2-init.d/rails ${random_password.postgres.result}",
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
