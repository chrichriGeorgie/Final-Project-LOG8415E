#
# LOG8415E - Final Project. Inspired by my team solution during the first assignment. 
# See this repo for the original code: https://github.com/chrichriGeorgie/Lab1-LOG8415E
#
# infra.tf
# Terraform configuration relative to instance definitions

# Declaring 1 t2 micro instance to host MySQL standalone
resource "aws_instance" "mysql_standalone_instance" {
  count                       = 1
  ami                         = "ami-0a6b2839d44d781b2"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  user_data = templatefile("./userdata/standalone-config.tftpl", {})
  subnet_id              = aws_subnet.standalone_net.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  key_name = "final_project"
  tags = {
    Name = "MySQL Standalone"
  }
}


# Declaring 1 t2 micro instance to be primary node of the MySQL cluster
resource "aws_instance" "mysql_primary_cluster_instance" {
  count                       = 1
  ami                         = "ami-0a6b2839d44d781b2"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  user_data = templatefile("./userdata/primary-config.sh.tftpl", {})
  subnet_id              = aws_subnet.cluster_net.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id, aws_security_group.mysql_cluster_sg.id]
  key_name = "final_project"
  tags = {
    Name = "MySQL Cluster Primary"
  }
}

# Declaring 3 t2 micro instances to be secondary nodes of the MySQL cluster
resource "aws_instance" "mysql_secondary_cluster_instances" {
  count                       = 3
  ami                         = "ami-0a6b2839d44d781b2"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  user_data = templatefile("./userdata/secondary-config.sh.tftpl", {})
  subnet_id              = aws_subnet.cluster_net.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id, aws_security_group.mysql_cluster_sg.id]
  key_name = "final_project"
  tags = {
    Name = "MySQL Cluster Secondary ${count.index}"
  }
}

# Declaring 1 t2 large instance to be the proxy
resource "aws_instance" "proxy_instance" {
  count                       = 1
  ami                         = "ami-0a6b2839d44d781b2"
  instance_type               = "t2.large"
  associate_public_ip_address = true
  user_data = templatefile("./userdata/proxy-config.sh.tftpl", {})
  subnet_id              = aws_subnet.cluster_net.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  key_name = "final_project"
  tags = {
    Name = "Proxy"
  }
}
