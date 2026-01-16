# AWS Provider Configuration Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

# Project Name
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-bootstrap"
}

# S3 Bucket Prefix
variable "s3_bucket_prefix" {
  description = "Prefix for S3 bucket name"
  type        = string
  default     = "terraform-state"
}

# DynamoDB Table Prefix
variable "dynamodb_table_prefix" {
  description = "Prefix for DynamoDB table name"
  type        = string
  default     = "terraform-locks"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}