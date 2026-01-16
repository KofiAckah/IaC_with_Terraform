# Local values for common configurations
locals {
  # Generate unique names
  s3_bucket_name      = "${var.s3_bucket_prefix}-${data.aws_caller_identity.current.account_id}"
  dynamodb_table_name = "${var.dynamodb_table_prefix}-${data.aws_caller_identity.current.account_id}"
  
  # Common tags
  common_tags = merge(
    {
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Purpose     = "Remote State Management"
    },
    var.tags
  )
}

# Get AWS account ID
data "aws_caller_identity" "current" {}

# S3 Backend Module
module "s3_backend" {
  source      = "./modules/s3_backend"
  bucket_name = local.s3_bucket_name
  tags        = local.common_tags
}

# DynamoDB Lock Module
module "dynamodb_lock" {
  source              = "./modules/dynamodb_lock"
  dynamodb_table_name = local.dynamodb_table_name
  tags                = local.common_tags
}