# =============================================================================
# MONITORING MODULE VARIABLES
# =============================================================================

# Basic Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name cannot be empty."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# =============================================================================
# INFRASTRUCTURE RESOURCE IDs (from other modules)
# =============================================================================

# VPC and Networking
variable "vpc_id" {
  description = "VPC ID where monitoring resources will be created"
  type        = string
}

# Load Balancer Resources
variable "load_balancer_arn" {
  description = "ARN of the Application Load Balancer to monitor"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group to monitor"
  type        = string
}

# Auto Scaling Group
variable "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group to monitor"
  type        = string
}

# RDS Database
variable "db_instance_identifier" {
  description = "RDS instance identifier to monitor"
  type        = string
}

# =============================================================================
# NOTIFICATION CONFIGURATION
# =============================================================================

variable "notification_email" {
  description = "Email address for alert notifications"
  type        = string
  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.notification_email))
    error_message = "Please provide a valid email address."
  }
}

variable "notification_phone" {
  description = "Phone number for SMS alerts (optional, format: +1234567890)"
  type        = string
  default     = ""
  validation {
    condition     = var.notification_phone == "" || can(regex("^\\+[1-9]\\d{1,14}$", var.notification_phone))
    error_message = "Phone number must be in international format (e.g., +1234567890)."
  }
}

# Slack Integration
variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "slack_critical_webhook_url" {
  description = "Slack incoming webhook URL for critical alerts (can be same as standard or different channel)"
  type        = string
  default     = ""
  sensitive   = true
}

# Microsoft Teams Integration
variable "teams_webhook_url" {
  description = "Microsoft Teams incoming webhook URL for alerts"
  type        = string
  default     = ""
  sensitive   = true
}

# Custom Webhook Integration (PagerDuty, OpsGenie, etc.)
variable "custom_webhook_url" {
  description = "Custom webhook URL for third-party integrations"
  type        = string
  default     = ""
  sensitive   = true
}

variable "custom_webhook_headers" {
  description = "Custom headers for webhook authentication (JSON format)"
  type        = string
  default     = ""
  sensitive   = true
}

# Notification Preferences
variable "enable_info_notifications" {
  description = "Enable email notifications for info-level alerts (can be noisy)"
  type        = bool
  default     = false
}

variable "enable_message_formatting" {
  description = "Enable Lambda-based message formatting for enhanced notifications"
  type        = bool
  default     = true
}

variable "cross_account_role_arns" {
  description = "List of cross-account role ARNs allowed to access SNS topics"
  type        = list(string)
  default     = []
}

# =============================================================================
# ALARM THRESHOLDS CONFIGURATION
# =============================================================================

# EC2 Instance Monitoring Thresholds
variable "ec2_cpu_threshold" {
  description = "CPU utilization percentage threshold for EC2 alarms"
  type        = number
  default     = 80
  validation {
    condition     = var.ec2_cpu_threshold > 0 && var.ec2_cpu_threshold <= 100
    error_message = "CPU threshold must be between 1 and 100."
  }
}

variable "ec2_memory_threshold" {
  description = "Memory utilization percentage threshold for EC2 alarms"
  type        = number
  default     = 85
  validation {
    condition     = var.ec2_memory_threshold > 0 && var.ec2_memory_threshold <= 100
    error_message = "Memory threshold must be between 1 and 100."
  }
}

# RDS Database Monitoring Thresholds
variable "rds_cpu_threshold" {
  description = "CPU utilization percentage threshold for RDS alarms"
  type        = number
  default     = 75
  validation {
    condition     = var.rds_cpu_threshold > 0 && var.rds_cpu_threshold <= 100
    error_message = "RDS CPU threshold must be between 1 and 100."
  }
}

variable "rds_connection_threshold" {
  description = "Number of database connections threshold"
  type        = number
  default     = 50
}

variable "rds_free_space_threshold" {
  description = "Free storage space threshold in bytes (default: 2GB)"
  type        = number
  default     = 2147483648  # 2GB in bytes
}

# Load Balancer Monitoring Thresholds
variable "alb_response_time_threshold" {
  description = "ALB response time threshold in seconds"
  type        = number
  default     = 1.0
  validation {
    condition     = var.alb_response_time_threshold > 0
    error_message = "Response time threshold must be greater than 0."
  }
}

variable "alb_error_rate_threshold" {
  description = "ALB error rate threshold as percentage"
  type        = number
  default     = 5
  validation {
    condition     = var.alb_error_rate_threshold > 0 && var.alb_error_rate_threshold <= 100
    error_message = "Error rate threshold must be between 1 and 100."
  }
}

# =============================================================================
# MONITORING CONFIGURATION
# =============================================================================

variable "evaluation_periods" {
  description = "Number of periods over which to evaluate the alarm"
  type        = number
  default     = 2
  validation {
    condition     = var.evaluation_periods >= 1
    error_message = "Evaluation periods must be at least 1."
  }
}

variable "alarm_period" {
  description = "Period in seconds for alarm evaluation"
  type        = number
  default     = 300  # 5 minutes
  validation {
    condition     = contains([60, 300, 900, 3600], var.alarm_period)
    error_message = "Alarm period must be 60, 300, 900, or 3600 seconds."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring (1-minute intervals)"
  type        = bool
  default     = false
}

# =============================================================================
# DASHBOARD CONFIGURATION
# =============================================================================

variable "dashboard_name" {
  description = "Name for the CloudWatch dashboard"
  type        = string
  default     = ""
}

variable "dashboard_widgets_per_row" {
  description = "Number of widgets per row in the dashboard"
  type        = number
  default     = 3
  validation {
    condition     = var.dashboard_widgets_per_row >= 1 && var.dashboard_widgets_per_row <= 6
    error_message = "Widgets per row must be between 1 and 6."
  }
}

# =============================================================================
# LOG RETENTION CONFIGURATION
# =============================================================================

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

# =============================================================================
# FEATURE TOGGLES
# =============================================================================

variable "enable_sns_notifications" {
  description = "Enable SNS notifications for alarms"
  type        = bool
  default     = true
}

variable "enable_dashboard" {
  description = "Create CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "enable_log_groups" {
  description = "Create CloudWatch log groups"
  type        = bool
  default     = true
}

variable "enable_ec2_monitoring" {
  description = "Enable EC2 instance monitoring"
  type        = bool
  default     = true
}

variable "enable_rds_monitoring" {
  description = "Enable RDS monitoring"
  type        = bool
  default     = true
}

variable "enable_alb_monitoring" {
  description = "Enable Application Load Balancer monitoring"
  type        = bool
  default     = true
}