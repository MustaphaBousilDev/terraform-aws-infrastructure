# =============================================================================
# CLOUDWATCH LOG GROUPS FOR APPLICATION LOGGING
# =============================================================================

# Application Server Logs
resource "aws_cloudwatch_log_group" "application" {
  count = var.enable_log_groups ? 1 : 0
  
  name              = "/aws/ec2/${var.project_name}-${var.environment}/application"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-app-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "application"
    Purpose     = "Application server logs and errors"
  }
}

# Web Server Access Logs (Apache/Nginx)
resource "aws_cloudwatch_log_group" "web_server" {
  count = var.enable_log_groups ? 1 : 0
  
  name              = "/aws/ec2/${var.project_name}-${var.environment}/web-server"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-web-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "web-server"
    Purpose     = "Web server access and error logs"
  }
}


# System Logs (OS level logs, security, etc.)
resource "aws_cloudwatch_log_group" "system" {
  count = var.enable_log_groups ? 1 : 0
  
  name              = "/aws/ec2/${var.project_name}-${var.environment}/system"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-system-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "system"
    Purpose     = "Operating system and security logs"
  }
}


# Application Error Logs (Critical errors, exceptions)
resource "aws_cloudwatch_log_group" "application_errors" {
  count = var.enable_log_groups ? 1 : 0
  
  name              = "/aws/ec2/${var.project_name}-${var.environment}/errors"
  retention_in_days = var.log_retention_days * 2  # Keep error logs longer
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-error-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "errors"
    Purpose     = "Application errors and exceptions"
  }
}

# Database Slow Query Logs (RDS/MySQL slow queries)
resource "aws_cloudwatch_log_group" "database_slow_query" {
  count = var.enable_log_groups && var.enable_rds_monitoring ? 1 : 0
  
  name              = "/aws/rds/instance/${var.project_name}-${var.environment}/slowquery"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-db-slow-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "database-slow"
    Purpose     = "Database slow query logs for performance analysis"
  }
}

# Database Error Logs (RDS/MySQL errors)
resource "aws_cloudwatch_log_group" "database_error" {
  count = var.enable_log_groups && var.enable_rds_monitoring ? 1 : 0
  
  name              = "/aws/rds/instance/${var.project_name}-${var.environment}/error"
  retention_in_days = var.log_retention_days * 2  # Keep database errors longer
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-db-error-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "database-error"
    Purpose     = "Database error logs for troubleshooting"
  }
}

# Load Balancer Access Logs (ALB requests)
resource "aws_cloudwatch_log_group" "load_balancer" {
  count = var.enable_log_groups && var.enable_alb_monitoring ? 1 : 0
  
  name              = "/aws/applicationloadbalancer/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "load-balancer"
    Purpose     = "Application Load Balancer access logs"
  }
}


# Security Logs (Authentication, authorization, suspicious activities)
resource "aws_cloudwatch_log_group" "security" {
  count = var.enable_log_groups ? 1 : 0
  
  name              = "/aws/security/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days * 3  # Keep security logs longest
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-security-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "security"
    Purpose     = "Security events, authentication, and access logs"
  }
}


# Performance Monitoring Logs (Custom metrics, performance data)
resource "aws_cloudwatch_log_group" "performance" {
  count = var.enable_log_groups ? 1 : 0
  
  name              = "/aws/performance/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-performance-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "performance"
    Purpose     = "Custom performance metrics and monitoring data"
  }
}

# Auto Scaling Logs (Scale up/down events, instance launches)
resource "aws_cloudwatch_log_group" "auto_scaling" {
  count = var.enable_log_groups && var.enable_ec2_monitoring ? 1 : 0
  
  name              = "/aws/autoscaling/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-autoscaling-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "auto-scaling"
    Purpose     = "Auto Scaling Group events and instance lifecycle logs"
  }
}

# =============================================================================
# LOG GROUPS FOR LAMBDA FUNCTIONS (If you add serverless components later)
# =============================================================================

# Lambda Function Logs (for future serverless additions)
resource "aws_cloudwatch_log_group" "lambda_functions" {
  count = var.enable_log_groups ? 1 : 0
  
  name              = "/aws/lambda/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-logs"
    Environment = var.environment
    Project     = var.project_name
    LogType     = "lambda"
    Purpose     = "AWS Lambda function execution logs"
  }
}

# =============================================================================
# LOG STREAM EXAMPLES (Optional - for structured logging)
# =============================================================================

# Application Log Stream for structured logging
resource "aws_cloudwatch_log_stream" "application_main" {
  count          = var.enable_log_groups ? 1 : 0
  name           = "main-application-stream"
  log_group_name = aws_cloudwatch_log_group.application[0].name
}

# Error Log Stream for critical errors
resource "aws_cloudwatch_log_stream" "critical_errors" {
  count          = var.enable_log_groups ? 1 : 0
  name           = "critical-errors-stream"
  log_group_name = aws_cloudwatch_log_group.application_errors[0].name
}


# =============================================================================
# OUTPUT LOG GROUP INFORMATION
# =============================================================================

# Export log group names for use in other modules or applications
locals {
  log_groups = var.enable_log_groups ? {
    application         = aws_cloudwatch_log_group.application[0].name
    web_server         = aws_cloudwatch_log_group.web_server[0].name
    system             = aws_cloudwatch_log_group.system[0].name
    application_errors = aws_cloudwatch_log_group.application_errors[0].name
    database_slow      = var.enable_rds_monitoring ? aws_cloudwatch_log_group.database_slow_query[0].name : ""
    database_error     = var.enable_rds_monitoring ? aws_cloudwatch_log_group.database_error[0].name : ""
    load_balancer      = var.enable_alb_monitoring ? aws_cloudwatch_log_group.load_balancer[0].name : ""
    security           = aws_cloudwatch_log_group.security[0].name
    performance        = aws_cloudwatch_log_group.performance[0].name
    auto_scaling       = var.enable_ec2_monitoring ? aws_cloudwatch_log_group.auto_scaling[0].name : ""
    lambda_functions   = aws_cloudwatch_log_group.lambda_functions[0].name
  } : {}
}






