output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.app_server.arn
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.app_server.public_dns
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.app_server.instance_state
}

output "ami_id" {
  description = "AMI ID used for the instance"
  value       = data.aws_ami.ubuntu.id
}

output "website_url" {
  description = "URL to access the website"
  value       = "http://${aws_instance.app_server.public_ip}"
}