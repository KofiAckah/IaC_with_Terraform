terraform {
  backend "s3" {
    bucket         = "iac-terraform-dev-tfstate"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "iac-terraform-dev-tfstate-lock"
    encrypt        = true
  }
}