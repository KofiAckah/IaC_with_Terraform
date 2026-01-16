# Call the S3 Backend Module
module "s3_backend" {
  source = "./modules/s3_backend"
  bucket_name = var.s3_bucket_name
}