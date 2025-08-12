# bootstrap/outputs.tf
# Outputs important information needed for backend configuration in environments

output "terraform_state_bucket" {
  description = "Name of the S3 bucket for storing Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_state_bucket_arn" {
  description = "ARN of the S3 bucket for storing Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "terraform_locks_table" {
  description = "Name of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "terraform_locks_table_arn" {
  description = "ARN of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

output "aws_region" {
  description = "AWS region where resources were created"
  value       = var.aws_region
}

# This output provides the backend configuration template
output "backend_config" {
  description = "Backend configuration for use in environment configurations"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    encrypt        = true
  }
}

# Helpful command for copying to environment backend.tf files
output "backend_config_template" {
  description = "Copy this configuration to your environment's backend.tf file"
  value = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.bucket}"
        environments/dev/terraform.tfstate
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.terraform_locks.name}"
        encrypt        = true
      }
    }
  EOT
}