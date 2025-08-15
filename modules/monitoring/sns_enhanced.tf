# =============================================================================
# ENHANCED SNS TOPICS AND SUBSCRIPTIONS FOR ADVANCED NOTIFICATIONS
# =============================================================================

# Additional variables for enhanced notifications (add to variables.tf)
variable "notification_emails" {
  description = "List of email addresses for different alert types"
  type = object({
    devops_team     = list(string)
    development_team = list(string)
    management_team  = list(string)
    on_call_engineer = string
  })
  default = {
    devops_team      = []
    development_team = []
    management_team  = []
    on_call_engineer = ""
  }
}



variable "webhook_endpoints" {
  description = "List of webhook endpoints for custom integrations"
  type = list(object({
    name = string
    url  = string
    auth_header = string
  }))
  default = []
  sensitive = true
}

variable "phone_number_critical" {
  description = "Phone number for critical alert voice calls"
  type        = string
  default     = ""
}

variable "enable_phone_calls" {
  description = "Enable phone call notifications for critical alerts"
  type        = bool
  default     = false
}

# =============================================================================
# ENHANCED SNS TOPIC POLICIES FOR SECURITY
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


# Policy for alerts topic
resource "aws_sns_topic_policy" "alerts_policy" {
  count = var.enable_sns_notifications ? 1 : 0
  
  arn = aws_sns_topic.alerts[0].arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchToPublish"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.alerts[0].arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
      {
        Sid    = "AllowAccountOwnerToManage"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "SNS:Subscribe",
          "SNS:Unsubscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes"
        ]
        Resource = aws_sns_topic.alerts[0].arn
      }
    ]
  })
}

# Policy for critical alerts topic
resource "aws_sns_topic_policy" "critical_alerts_policy" {
  count = var.enable_sns_notifications ? 1 : 0
  
  arn = aws_sns_topic.critical_alerts[0].arn
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchToPublish"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.critical_alerts[0].arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# =============================================================================
# MULTIPLE EMAIL SUBSCRIPTIONS FOR DIFFERENT TEAMS
# =============================================================================

# DevOps team email subscriptions for all alerts
resource "aws_sns_topic_subscription" "devops_alerts" {
  count = var.enable_sns_notifications && length(var.notification_emails.devops_team) > 0 ? length(var.notification_emails.devops_team) : 0
  
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_emails.devops_team[count.index]
  
  # Add filter policy to reduce noise for DevOps team
  filter_policy = jsonencode({
    severity = ["medium", "high", "critical"]
  })
}

# DevOps team critical alerts
resource "aws_sns_topic_subscription" "devops_critical_alerts" {
  count = var.enable_sns_notifications && length(var.notification_emails.devops_team) > 0 ? length(var.notification_emails.devops_team) : 0
  
  topic_arn = aws_sns_topic.critical_alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_emails.devops_team[count.index]
}

# Development team email subscriptions (application-related alerts only)
resource "aws_sns_topic_subscription" "dev_team_alerts" {
  count = var.enable_sns_notifications && length(var.notification_emails.development_team) > 0 ? length(var.notification_emails.development_team) : 0
  
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_emails.development_team[count.index]
  
  # Filter for application-related alerts only
  filter_policy = jsonencode({
    alert_type = ["application-errors", "database-performance", "load-balancer-errors"]
  })
}

# Management team email subscriptions (critical and cost-related alerts)
resource "aws_sns_topic_subscription" "management_alerts" {
  count = var.enable_sns_notifications && length(var.notification_emails.management_team) > 0 ? length(var.notification_emails.management_team) : 0
  
  topic_arn = aws_sns_topic.critical_alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_emails.management_team[count.index]
}

# Management team cost optimization alerts
resource "aws_sns_topic_subscription" "management_cost_alerts" {
  count = var.enable_sns_notifications && length(var.notification_emails.management_team) > 0 ? length(var.notification_emails.management_team) : 0
  
  topic_arn = aws_sns_topic.info_alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_emails.management_team[count.index]
  
  # Filter for cost optimization alerts
  filter_policy = jsonencode({
    alert_type = ["cost-optimization"]
  })
}

# On-call engineer direct notification
resource "aws_sns_topic_subscription" "on_call_critical" {
  count = var.enable_sns_notifications && var.notification_emails.on_call_engineer != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.critical_alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_emails.on_call_engineer
}

# =============================================================================
# PHONE CALL NOTIFICATIONS FOR CRITICAL ALERTS
# =============================================================================

# Phone call subscription for critical alerts
resource "aws_sns_topic_subscription" "phone_critical_alerts" {
  count = var.enable_sns_notifications && var.enable_phone_calls && var.phone_number_critical != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.critical_alerts[0].arn
  protocol  = "sms"  # Note: Voice calls require AWS Connect or third-party service
  endpoint  = var.phone_number_critical
}

# =============================================================================
# LAMBDA FUNCTION FOR SLACK NOTIFICATIONS
# =============================================================================

# IAM role for Slack notification Lambda
resource "aws_iam_role" "slack_notification_lambda_role" {
  count = var.enable_sns_notifications && var.slack_webhook_url != "" ? 1 : 0
  
  name = "${var.project_name}-${var.environment}-slack-notification-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-slack-lambda-role"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "IAM role for Slack notification Lambda function"
  }
}

# IAM policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "slack_lambda_basic_execution" {
  count = var.enable_sns_notifications && var.slack_webhook_url != "" ? 1 : 0
  
  role       = aws_iam_role.slack_notification_lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function for Slack notifications
resource "aws_lambda_function" "slack_notification" {
  count = var.enable_sns_notifications && var.slack_webhook_url != "" ? 1 : 0
  
  filename         = "slack_notification.zip"
  function_name    = "${var.project_name}-${var.environment}-slack-notification"
  role            = aws_iam_role.slack_notification_lambda_role[0].arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30
  
  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      PROJECT_NAME      = var.project_name
      ENVIRONMENT       = var.environment
    }
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-slack-notification"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Send CloudWatch alerts to Slack"
  }
}

# Create the Lambda deployment package
data "archive_file" "slack_notification_zip" {
  count = var.enable_sns_notifications && var.slack_webhook_url != "" ? 1 : 0
  
  type        = "zip"
  output_path = "slack_notification.zip"
  
  source {
    content = templatefile("${path.module}/lambda/slack_notification.py", {
      webhook_url = var.slack_webhook_url
    })
    filename = "index.py"
  }
}

# Lambda permission for SNS to invoke the function
resource "aws_lambda_permission" "allow_sns_slack" {
  count = var.enable_sns_notifications && var.slack_webhook_url != "" ? 1 : 0
  
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notification[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.critical_alerts[0].arn
}

# SNS subscription for Slack notifications
resource "aws_sns_topic_subscription" "slack_critical_alerts" {
  count = var.enable_sns_notifications && var.slack_webhook_url != "" ? 1 : 0
  
  topic_arn = aws_sns_topic.critical_alerts[0].arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notification[0].arn
}

# =============================================================================
# WEBHOOK NOTIFICATIONS FOR CUSTOM INTEGRATIONS
# =============================================================================

# Lambda function for webhook notifications
resource "aws_lambda_function" "webhook_notification" {
  count = var.enable_sns_notifications && length(var.webhook_endpoints) > 0 ? 1 : 0
  
  filename         = "webhook_notification.zip"
  function_name    = "${var.project_name}-${var.environment}-webhook-notification"
  role            = aws_iam_role.webhook_notification_lambda_role[0].arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30
  
  environment {
    variables = {
      WEBHOOK_ENDPOINTS = jsonencode(var.webhook_endpoints)
      PROJECT_NAME      = var.project_name
      ENVIRONMENT       = var.environment
    }
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-webhook-notification"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Send CloudWatch alerts to webhook endpoints"
  }
}

# IAM role for webhook notification Lambda
resource "aws_iam_role" "webhook_notification_lambda_role" {
  count = var.enable_sns_notifications && length(var.webhook_endpoints) > 0 ? 1 : 0
  
  name = "${var.project_name}-${var.environment}-webhook-notification-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy attachment for webhook Lambda
resource "aws_iam_role_policy_attachment" "webhook_lambda_basic_execution" {
  count = var.enable_sns_notifications && length(var.webhook_endpoints) > 0 ? 1 : 0
  
  role       = aws_iam_role.webhook_notification_lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create webhook Lambda deployment package
data "archive_file" "webhook_notification_zip" {
  count = var.enable_sns_notifications && length(var.webhook_endpoints) > 0 ? 1 : 0
  
  type        = "zip"
  output_path = "webhook_notification.zip"
  
  source {
    content = templatefile("${path.module}/lambda/webhook_notification.py", {
      webhook_endpoints = jsonencode(var.webhook_endpoints)
    })
    filename = "index.py"
  }
}

# Lambda permission for webhook notifications
resource "aws_lambda_permission" "allow_sns_webhook" {
  count = var.enable_sns_notifications && length(var.webhook_endpoints) > 0 ? 1 : 0
  
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.webhook_notification[0].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts[0].arn
}

# SNS subscription for webhook notifications
resource "aws_sns_topic_subscription" "webhook_alerts" {
  count = var.enable_sns_notifications && length(var.webhook_endpoints) > 0 ? 1 : 0
  
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.webhook_notification[0].arn
}

# =============================================================================
# DEAD LETTER QUEUES FOR FAILED NOTIFICATIONS
# =============================================================================

# SQS Dead Letter Queue for failed notifications
resource "aws_sqs_queue" "notification_dlq" {
  count = var.enable_sns_notifications ? 1 : 0
  
  name                      = "${var.project_name}-${var.environment}-notification-dlq"
  message_retention_seconds = 1209600  # 14 days
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-notification-dlq"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Dead letter queue for failed SNS notifications"
  }
}

# CloudWatch alarm for messages in DLQ
resource "aws_cloudwatch_metric_alarm" "notification_dlq_messages" {
  count = var.enable_sns_notifications ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-notification-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfVisibleMessages"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Failed notifications detected in dead letter queue"
  alarm_actions       = [aws_sns_topic.critical_alerts[0].arn]
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    QueueName = aws_sqs_queue.notification_dlq[0].name
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-dlq-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "notification-health"
    Severity    = "high"
    Purpose     = "Monitor failed notification delivery"
  }
}