#
# LOG8415E - Final Project. Inspired by my team solution during the first assignment. 
# See this repo for the original code: https://github.com/chrichriGeorgie/Lab1-LOG8415E
#
# infra.tf
# Terraform configuration relative to instance definitions

# Declaring 1 t2 micro instance to host MySQL standalone
resource "aws_instance" "mysql_standalone_intance" {
  count                       = 1
  ami                         = "ami-0a6b2839d44d781b2"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  user_data = templatefile("./userdata/standalone-config.sh.tftpl", {})
  subnet_id              = aws_subnet.cluster2_subnet.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
}


# Declaring 4 t2 micro instance to be part of the MySQL cluster
resource "aws_instance" "mysql_cluster_intances" {
  count                       = 4
  ami                         = "ami-0a6b2839d44d781b2"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  user_data = templatefile("./userdata/instance-config.sh.tftpl", {})
  subnet_id              = aws_subnet.cluster2_subnet.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
}

# Declaring 1 t2 large instance to be the proxy
resource "aws_instance" "proxy_intance" {
  count                       = 1
  ami                         = "ami-0a6b2839d44d781b2"
  instance_type               = "t2.large"
  associate_public_ip_address = true
  user_data = templatefile("./userdata/instance-config.sh.tftpl", {})
  subnet_id              = aws_subnet.cluster2_subnet.id
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
}
