terraform {
  backend "s3" {
    bucket         = "terraformawsinfrastructure-terraform-state-7a6gvevg"
    key            = "environments/staging-v2/terraform.tfstate" # ← Add -v2
    region         = "us-east-1"
    dynamodb_table = "terraformawsinfrastructure-terraform-locks"
    encrypt        = true
  }
}