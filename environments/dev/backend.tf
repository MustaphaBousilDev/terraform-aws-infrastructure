terraform {
  backend "s3" {
    bucket         = "terraformawsinfrastructure-terraform-state-7a6gvevg"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraformawsinfrastructure-terraform-locks"
    encrypt        = true
  }
}

