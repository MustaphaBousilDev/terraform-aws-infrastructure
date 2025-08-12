output "test_bucket_name" {
  description = "Name of the test S3 bucket"
  value       = aws_s3_bucket.test.bucket
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}