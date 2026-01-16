# AWS Provider Configuration Variables
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

# S3 Bucket Configuration Variables
variable "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
  default     = "my-terraform-state-bucket"
}