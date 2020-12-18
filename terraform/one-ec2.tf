new-one.tf

# Paste these three secrets into bash from https://atc-ad.awsapps.com/start#/ :
# export AWS_ACCESS_KEY_ID=...
# export AWS_SECRET_KEY_ID=...
# export AWS_SESSION_TOKEN=...
# and also:
# export AWS_DEFAULT_REGION=us-east-1
variable "ssh_public_key_path" {
  default = "/Users/morsed/.ssh/contradb-terraform.pub"
}

provider "aws" {}

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

resource "aws_instance" "contradb" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.nano"

  tags = {
    Name = "contradb"
  }

  key_name = aws_key_pair.contradb_terraform.key_name

  security_groups = [aws_security_group.allow_ssh.id]
  # delete_on_termination = eventually false, but for now true is aok
  # might need a aws_network_interface, but probably can get away with the network_interface block
}

resource "aws_key_pair" "contradb_terraform" {
  key_name   = "contradb-terraform-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

output "ip" {
  value = aws_instance.contradb.public_ip
}

output "host" {
  value = aws_instance.contradb.public_dns
}