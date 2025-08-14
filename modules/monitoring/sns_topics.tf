# =============================================================================
# SNS TOPICS FOR ALARM NOTIFICATIONS
# =============================================================================

# Main Alerts Topic (Medium severity alerts)
resource "aws_sns_topic" "alerts" {
  count = var.enable_sns_notifications ? 1 : 0
  
  name = "${var.project_name}-${var.environment}-alerts"
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alerts-topic"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Standard severity alerts and notifications"
  }
}

# Critical Alerts Topic (High severity alerts)
resource "aws_sns_topic" "critical_alerts" {
  count = var.enable_sns_notifications ? 1 : 0
  
  name = "${var.project_name}-${var.environment}-critical-alerts"
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-critical-alerts-topic"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Critical severity alerts requiring immediate attention"
  }
}

# Info Alerts Topic (Low severity, informational)
resource "aws_sns_topic" "info_alerts" {
  count = var.enable_sns_notifications ? 1 : 0
  
  name = "${var.project_name}-${var.environment}-info-alerts"
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-info-alerts-topic"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Informational alerts and cost optimization notifications"
  }
}

# =============================================================================
# EMAIL SUBSCRIPTIONS
# =============================================================================

# Email subscription for standard alerts
resource "aws_sns_topic_subscription" "email_alerts" {
  count = var.enable_sns_notifications && var.notification_email != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Email subscription for critical alerts
resource "aws_sns_topic_subscription" "email_critical_alerts" {
  count = var.enable_sns_notifications && var.notification_email != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.critical_alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}


# Email subscription for info alerts
resource "aws_sns_topic_subscription" "email_info_alerts" {
  count = var.enable_sns_notifications && var.notification_email != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.info_alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# =============================================================================
# SMS SUBSCRIPTIONS (Optional)
# =============================================================================

# SMS subscription for critical alerts only
resource "aws_sns_topic_subscription" "sms_critical_alerts" {
  count = var.enable_sns_notifications && var.notification_phone != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.critical_alerts[0].arn
  protocol  = "sms"
  endpoint  = var.notification_phone
}