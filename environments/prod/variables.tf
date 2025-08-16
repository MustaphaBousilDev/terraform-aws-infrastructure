# AWS Configuration
variable "aws_region" {
  description = "AWS region for production deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraformawsinfrastructure"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}


variable "instance_type" {
  description = "EC2 instance type for production"
  type        = string
  default     = "t3.large"
}

variable "min_size" {
  description = "Minimum number of instances in auto scaling group"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Maximum number of instances in auto scaling group"
  type        = number
  default     = 20
}


variable "db_instance_class" {
  description = "RDS instance class for production"
  type        = string
  default     = "db.r5.large"
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = true
}

variable "backup_retention" {
  description = "Backup retention period in days"
  type        = number
  default     = 30
}

# Monitoring Configuration
variable "detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

# Security Configuration
variable "enable_deletion_protection" {
  description = "Enable deletion protection for critical resources"
  type        = bool
  default     = true
}