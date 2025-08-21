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

# Use networking module
module "networking" {
  source = "../../modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

# Test S3 bucket
/*resource "aws_s3_bucket" "test" {
  bucket = "${var.project_name}-${var.environment}-test"
}*/

# Compute module
module "compute" {
  source = "../../modules/compute"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  instance_type      = "t3.micro"

  # Database endpoints for application use
  primary_db_endpoint   = module.database.db_instance_endpoint
  read_replica_endpoint = module.database.db_read_replica_endpoint
}


# Database module
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


# =============================================================================
# MONITORING MODULE - ADD THIS ENTIRE SECTION
# =============================================================================

module "monitoring" {
  source = "../../modules/monitoring"

  # Basic Configuration
  project_name = var.project_name
  environment  = var.environment

  # Infrastructure Resource IDs (from other modules)
  vpc_id                  = module.networking.vpc_id
  load_balancer_arn       = module.compute.alb_arn
  target_group_arn        = module.compute.target_group_arn
  auto_scaling_group_name = module.compute.autoscaling_group_name
  db_instance_identifier  = module.database.db_instance_id

  # =============================================================================
  # NOTIFICATION CONFIGURATION - CUSTOMIZE THESE SETTINGS
  # =============================================================================

  # Primary notification email (REQUIRED - replace with your email)
  notification_email = "admin@yourcompany.com" # ← CHANGE THIS TO YOUR EMAIL

  # Optional: SMS notifications
  notification_phone = "+1234567890" # ← ADD YOUR PHONE NUMBER (optional)

  # Enhanced team-based notifications (OPTIONAL - configure as needed)
  notification_emails = {
    devops_team = [
      "devops@yourcompany.com", # ← ADD YOUR DEVOPS TEAM EMAILS
      "admin@yourcompany.com"
    ]
    development_team = [
      "developers@yourcompany.com" # ← ADD YOUR DEVELOPMENT TEAM EMAILS
    ]
    management_team = [
      # "manager@yourcompany.com"   # ← ADD MANAGEMENT EMAILS (optional)
    ]
    on_call_engineer = "oncall@yourcompany.com" # ← ADD ON-CALL EMAIL
  }

  # Slack integration (OPTIONAL - add your Slack webhook URL)
  slack_webhook_url = "" # ← ADD YOUR SLACK WEBHOOK URL HERE
  # Example: "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"

  # Custom webhook endpoints (OPTIONAL - for PagerDuty, JIRA, etc.)
  webhook_endpoints = []
  # Example:
  # webhook_endpoints = [
  #   {
  #     name        = "PagerDuty"
  #     url         = "https://events.pagerduty.com/v2/enqueue"
  #     auth_header = "Authorization: Token token=YOUR_PAGERDUTY_TOKEN"
  #   }
  # ]

  # Phone call notifications for critical alerts (OPTIONAL)
  enable_phone_calls    = false # Set to true if you want phone call alerts
  phone_number_critical = ""    # Add phone number for critical alerts

  # =============================================================================
  # ALARM THRESHOLDS - CUSTOMIZE BASED ON YOUR NEEDS
  # =============================================================================

  # EC2 Instance Monitoring Thresholds
  ec2_cpu_threshold    = 80 # Trigger alert when CPU > 80%
  ec2_memory_threshold = 85 # Trigger alert when memory > 85%

  # RDS Database Monitoring Thresholds
  rds_cpu_threshold        = 75         # Database CPU threshold
  rds_connection_threshold = 50         # Maximum database connections
  rds_free_space_threshold = 2147483648 # 2GB free space minimum

  # Application Load Balancer Thresholds
  alb_response_time_threshold = 1.0 # Response time > 1 second
  alb_error_rate_threshold    = 5   # Error rate > 5%

  # =============================================================================
  # MONITORING FEATURE TOGGLES
  # =============================================================================

  # Enable/disable monitoring components
  enable_sns_notifications   = true  # Email/SMS notifications
  enable_dashboard           = true  # CloudWatch dashboard
  enable_log_groups          = true  # Application log groups
  enable_ec2_monitoring      = true  # EC2 instance monitoring
  enable_rds_monitoring      = true  # Database monitoring
  enable_alb_monitoring      = true  # Load balancer monitoring
  enable_detailed_monitoring = false # 1-minute intervals (costs more, set to true for production)

  # =============================================================================
  # MONITORING CONFIGURATION
  # =============================================================================

  # Alarm evaluation settings
  evaluation_periods = 2   # Number of consecutive periods before triggering alarm
  alarm_period       = 300 # Period length in seconds (300 = 5 minutes)

  # Log retention
  log_retention_days = 30 # Keep logs for 30 days (increase for production)

  enable_cloudfront_monitoring = true
  cloudfront_distribution_id   = module.storage.cloudfront_distribution_id


  #redis monitoring 
  enable_redis_monitoring = true
  redis_cluster_id        = module.caching.redis_endpoint # May need to be redis_cluster_id from caching outputs

}

module "caching" {
  source = "../../modules/caching"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  app_security_group_id = module.compute.app_security_group_id
  redis_node_type       = "cache.t3.micro"
}

module "security_waf" {
  source = "../../modules/security-waf"

  project_name      = var.project_name
  environment       = var.environment
  load_balancer_arn = module.compute.alb_arn
}