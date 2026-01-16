#Outputs for S3 Backend Module

output "bucket_id" {
  description = "The ID of the S3 bucket used for Terraform state"
  value       = module.s3_backend.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for Terraform state"
  value       = module.s3_backend.s3_bucket_arn
}

output "s3_bucket_region" {
  description = "The region of the S3 bucket used for Terraform state"
  value       = module.s3_backend.s3_bucket_region
}