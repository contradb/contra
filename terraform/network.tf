resource "aws_vpc" "contra_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "contradb"
  }
}

resource "aws_eip" "web_ip" {
  instance = aws_instance.server.id
  vpc      = true
  tags = {
    Name = "contradb"
  }
}

resource "aws_subnet" "web" {
  cidr_block        = cidrsubnet(aws_vpc.contra_vpc.cidr_block, 3, 1)
  vpc_id            = aws_vpc.contra_vpc.id
  availability_zone = "us-east-2a"
  tags = {
    Name = "contradb"
  }
}
resource "aws_route_table" "table" {
  vpc_id = aws_vpc.contra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "contradb"
  }
}
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.table.id
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.contra_vpc.id
  tags = {
    Name = "contradb"
  }
}
