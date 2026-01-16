#Outputs for S3 Backend Module
output "bucket_id" {
  description = "The ID of the S3 bucket used for Terraform state"
  value       = module.s3_backend.s3_bucket_id
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  value       = module.s3_backend.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3_backend.s3_bucket_arn
}

output "s3_bucket_region" {
  description = "The region of the S3 bucket used for Terraform state"
  value       = module.s3_backend.s3_bucket_region
}

#Outputs for DynamoDB Lock Module
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table used for Terraform state locking"
  value       = module.dynamodb_lock.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = module.dynamodb_lock.dynamodb_table_arn
}

# Backend Configuration (for reference)
output "backend_config" {
  description = "Backend configuration for use in infrastructure code"
  value = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${module.s3_backend.s3_bucket_id}"
        key            = "terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${module.dynamodb_lock.dynamodb_table_name}"
        encrypt        = true
      }
    }
  EOT
}