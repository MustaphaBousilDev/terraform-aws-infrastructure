# Environment Information
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
  description = "VPC ID for production"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

# Compute outputs
output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.compute.alb_dns_name
}

output "load_balancer_url" {
  description = "Production application URL"
  value       = "https://${module.compute.alb_dns_name}"  # Use HTTPS for prod
}

output "autoscaling_group_name" {
  description = "Auto scaling group name"
  value       = module.compute.autoscaling_group_name
}

# Database outputs
output "database_endpoint" {
  description = "Production database endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true  # Hide from logs for security
}

output "database_port" {
  description = "Database port"
  value       = module.database.db_instance_port
}

# Storage outputs
output "app_storage_bucket" {
  description = "Production application storage bucket"
  value       = module.storage.app_storage_bucket_name
}

output "static_assets_bucket" {
  description = "Production static assets bucket"
  value       = module.storage.static_assets_bucket_name
}

output "logs_bucket" {
  description = "Production logs bucket"
  value       = module.storage.logs_bucket_name
}

# Security outputs
output "kms_key_id" {
  description = "Production KMS encryption key ID"
  value       = module.security.kms_key_id
  sensitive   = true
}

output "db_secret_name" {
  description = "Database secret name in Secrets Manager"
  value       = module.security.db_secret_name
}

output "ec2_instance_profile" {
  description = "EC2 instance profile for production"
  value       = module.security.ec2_instance_profile_name
}

# Monitoring outputs
output "monitoring_dashboard_url" {
  description = "CloudWatch dashboard URL for production monitoring"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.project_name}-${var.environment}"
}

output "sns_alerts_topic" {
  description = "SNS topic ARN for production alerts"
  value       = module.monitoring.sns_topic_alerts_arn
  sensitive   = true
}

output "sns_critical_alerts_topic" {
  description = "SNS topic ARN for critical production alerts"
  value       = module.monitoring.sns_topic_critical_alerts_arn
  sensitive   = true
}

# Production-specific summary
output "production_deployment_summary" {
  description = "Production deployment summary"
  value = {
    environment     = var.environment
    instance_type   = var.instance_type
    vpc_cidr       = "10.2.0.0/16"
    multi_az       = "3 Availability Zones"
    backup_retention = "${var.log_retention_days} days"
    monitoring     = "Enhanced monitoring enabled"
    security_level = "Production grade"
  }
}

# Infrastructure endpoints for health checks
output "health_check_endpoints" {
  description = "Production health check endpoints"
  value = {
    load_balancer = "https://${module.compute.alb_dns_name}/health"
    database     = module.database.db_instance_endpoint
    monitoring   = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}"
  }
  sensitive = true
}