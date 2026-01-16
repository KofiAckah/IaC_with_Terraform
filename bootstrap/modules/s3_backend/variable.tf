# Variable definitions for S3 backend module
variable "bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}