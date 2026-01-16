output "vpc_cidr" {
  description = "The CIDR block of the created VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the created public subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "The ID of the created internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "The ID of the created public route table"
  value       = aws_route_table.public_rt.id
}