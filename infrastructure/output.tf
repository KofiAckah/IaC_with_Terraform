# Network Outputs
# VPC outputs
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the created VPC"
  value       = module.network.vpc_cidr
}

# Subnet outputs
output "public_subnet_id" {
  description = "The ID of the created public subnet"
  value       = module.network.public_subnet_id
}

# Internet Gateway outputs
output "internet_gateway_id" {
  description = "The ID of the created internet gateway"
  value       = module.network.internet_gateway_id
}

# Route Table outputs
output "public_route_table_id" {
  description = "The ID of the created public route table"
  value       = module.network.public_route_table_id
}