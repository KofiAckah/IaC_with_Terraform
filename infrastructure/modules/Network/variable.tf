# VPC cidr
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

# Project Name
variable "project_name" {
  description = "The name of the project"
  type        = string
}

# Environment
variable "environment" {
  description = "The deployment environment (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

# Common Tags
variable "common_tags" {
  description = "A map of common tags to apply to all resources"
  type        = map(string)
}