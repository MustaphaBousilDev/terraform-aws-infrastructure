terraform {
  backend "s3" {
    bucket  = "terraformawsinfrastructure-terraform-state-7a6gvevg"
    key     = "environments/staging-v2/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

    # New way to enable locking
    dynamodb_table = "terraformawsinfrastructure-terraform-locks" # Still works for now
  }
}