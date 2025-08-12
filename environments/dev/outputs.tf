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

# Networking outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}


output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.compute.alb_dns_name
}

output "load_balancer_url" {
  description = "Load balancer URL"
  value       = "http://${module.compute.alb_dns_name}"
}

