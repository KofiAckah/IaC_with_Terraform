output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app_sg.id
}

output "app_security_group_arn" {
  description = "ARN of the application security group"
  value       = aws_security_group.app_sg.arn
}

output "app_security_group_name" {
  description = "Name of the application security group"
  value       = aws_security_group.app_sg.name
}

output "app_security_group_rules" {
  description = "List of security group rules for the application security group"
  value = [
    aws_vpc_security_group_ingress_rule.allow_http_ingress.id,
    aws_vpc_security_group_ingress_rule.allow_https_ingress.id,
    aws_vpc_security_group_ingress_rule.allow_ssh_ingress.id,
    aws_vpc_security_group_egress_rule.allow_all_egress.id
  ]
}