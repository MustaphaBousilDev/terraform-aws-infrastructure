terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Enhanced networking for production
module "networking" {
  source = "../../modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = "10.2.0.0/16"                              # Different CIDR for prod
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"] # 3 AZs
}

# Production compute (using supported variables only)
module "compute" {
  source = "../../modules/compute"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  instance_type      = var.instance_type # t3.large

  # Database endpoints for application use
  primary_db_endpoint   = module.database.db_instance_endpoint
  read_replica_endpoint = module.database.db_read_replica_endpoint
}

# Production database (using supported variables only)
module "database" {
  source = "../../modules/database"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  app_security_group_id = module.compute.app_security_group_id
  db_password           = "MySecurePassword123!"
}

# Storage module
module "storage" {
  source = "../../modules/storage"

  project_name       = var.project_name
  environment        = var.environment
  enable_versioning  = true
  enable_public_read = false
}

# Security module
module "security" {
  source = "../../modules/security"

  project_name           = var.project_name
  environment            = var.environment
  db_password            = "MySecurePassword123!"
  create_ssl_certificate = false
  domain_name            = ""
}

# Monitoring module
module "monitoring" {
  source = "../../modules/monitoring"

  project_name = var.project_name
  environment  = var.environment

  vpc_id                  = module.networking.vpc_id
  load_balancer_arn       = module.compute.alb_arn
  target_group_arn        = module.compute.target_group_arn
  auto_scaling_group_name = module.compute.autoscaling_group_name
  db_instance_identifier  = module.database.db_instance_id

  notification_email = "prod-admin@yourcompany.com"
  notification_phone = "+1234567890"

  notification_emails = {
    devops_team = [
      "devops@yourcompany.com",
      "prod-admin@yourcompany.com"
    ]
    development_team = [
      "developers@yourcompany.com"
    ]
    management_team = [
      "manager@yourcompany.com"
    ]
    on_call_engineer = "oncall@yourcompany.com"
  }

  slack_webhook_url = ""
  webhook_endpoints = []

  enable_phone_calls    = false
  phone_number_critical = ""

  # Production thresholds (more sensitive)
  ec2_cpu_threshold        = 70 # Lower threshold for prod
  ec2_memory_threshold     = 75
  rds_cpu_threshold        = 60
  rds_connection_threshold = 40
  rds_free_space_threshold = 2147483648

  alb_response_time_threshold = 0.5 # Faster response time for prod
  alb_error_rate_threshold    = 2   # Lower error tolerance

  enable_sns_notifications   = true
  enable_dashboard           = true
  enable_log_groups          = true
  enable_ec2_monitoring      = true
  enable_rds_monitoring      = true
  enable_alb_monitoring      = true
  enable_detailed_monitoring = true # Enable for production

  evaluation_periods = 2
  alarm_period       = 300
  log_retention_days = var.log_retention_days # 90 days


  enable_cloudfront_monitoring = true
  cloudfront_distribution_id   = module.storage.cloudfront_distribution_id

  #redis monitoring 
  enable_redis_monitoring = true 
  redis_cluster_id       = module.caching.redis_endpoint # May need to be redis_cluster_id from caching outputs

}

module "caching" {
  source = "../../modules/caching"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  app_security_group_id = module.compute.app_security_group_id
  redis_node_type       = "cache.t3.large"
}