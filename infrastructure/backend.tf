terraform {
  backend "s3" {
    bucket         = "terraform-state-605134436600"
    key            = "infrastructure/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks-605134436600"
    encrypt        = true
  }
}