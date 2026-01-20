# AWS Provider Configuration Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-central-1"
}

# Project Name
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "iac-terraform"
}

# Environment
variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
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

# Compute Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
}

# Owner Configuration
variable "owner" {
  description = "Owner of the infrastructure resources"
  type        = string
  default     = "livingstone-ackah"
}