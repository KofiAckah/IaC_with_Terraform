# Security group for the application servers
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-${var.environment}-app-sg"
  description = "Security group for application servers"
  vpc_id      = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-app-sg"
    }
  )
}

# Ingress rule to allow HTTP traffic from anywhere
resource "aws_vpc_security_group_ingress_rule" "allow_http_ingress" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "Allow HTTP traffic from anywhere"
}

# Ingress rule to allow HTTPS traffic from anywhere
resource "aws_vpc_security_group_ingress_rule" "allow_https_ingress" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Allow HTTPS traffic from anywhere"
}

# Ingress rule to allow SSH traffic from VPC CIDR only
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ingress" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "Allow SSH from VPC CIDR only"
}

# Egress rule to allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
  description       = "Allow all outbound traffic"
}