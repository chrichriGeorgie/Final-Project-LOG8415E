#
# LOG8415E - Final Project. Inspired by my team solution during the first assignment. 
# See this repo for the original code: https://github.com/chrichriGeorgie/Lab1-LOG8415E
#
# network.tf
# Terraform configuration relative to networking configuration

# Custom virtual private cloud for private addresses behind the load balancer
resource "aws_vpc" "vpc" {
  cidr_block         = "10.0.0.0/16"
  enable_dns_support = true
}

# Defining one subnet for the standalone MySQL
resource "aws_subnet" "standalone_net" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

#Defining one subnet for the Proxy and the MySQL Saikila cluster
resource "aws_subnet" "cluster_net" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

# Virtual private cloud configuration
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "rt_a_standalone" {
  subnet_id      = aws_subnet.standalone_net.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "rt_a_cluster" {
  subnet_id      = aws_subnet.cluster_net.id
  route_table_id = aws_route_table.public_rt.id
}

# Security group rules to allow ssh and mysql on the instances from all addresses
resource "aws_security_group" "mysql_sg" {
  name   = "MySQL"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group rules to allow ssh and mysql on the MySQL cluster from all addresses
resource "aws_security_group" "mysql_cluster_sg" {
  name   = "MySQLCluster"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 1186
    to_port     = 1186
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}