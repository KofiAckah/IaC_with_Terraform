# AWS Provider Configuration Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

# Project Name
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "iac-terraform"
}

# Common Tags
variable "common_tags" {
  description = "A map of common tags to apply to all resources"
  type        = map(string)
  default     = {
    ManagedBy   = "Terraform"
    Environment = "dev"
    CostCenter  = "Development"
    Department  = "Engineering"
  }
}

# VPC CIDR Block
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}