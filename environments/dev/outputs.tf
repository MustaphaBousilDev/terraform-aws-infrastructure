

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

# Compute outputs
output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.compute.alb_dns_name
}

output "load_balancer_url" {
  description = "Load balancer URL"
  value       = "http://${module.compute.alb_dns_name}"
}

# Database outputs
output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_instance_endpoint
}

output "database_port" {
  description = "Database port"
  value       = module.database.db_instance_port
}

# Storage outputs
output "app_storage_bucket" {
  description = "Application storage bucket name"
  value       = module.storage.app_storage_bucket_name
}

output "static_assets_bucket" {
  description = "Static assets bucket name"
  value       = module.storage.static_assets_bucket_name
}

output "logs_bucket" {
  description = "Logs bucket name"
  value       = module.storage.logs_bucket_name
}

# Security outputs
output "kms_key_id" {
  description = "KMS encryption key ID"
  value       = module.security.kms_key_id
}

output "db_secret_name" {
  description = "Database secret name in Secrets Manager"
  value       = module.security.db_secret_name
}

output "ec2_instance_profile" {
  description = "EC2 instance profile name"
  value       = module.security.ec2_instance_profile_name
}


