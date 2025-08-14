# =============================================================================
# MONITORING MODULE OUTPUTS
# =============================================================================

# Log Groups
output "log_groups" {
  description = "Map of all created CloudWatch log groups"
  value       = local.log_groups
}

# SNS Topics
output "sns_topic_alerts_arn" {
  description = "ARN of the main alerts SNS topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.alerts[0].arn : null
}

output "sns_topic_critical_alerts_arn" {
  description = "ARN of the critical alerts SNS topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.critical_alerts[0].arn : null
}

output "sns_topic_info_alerts_arn" {
  description = "ARN of the info alerts SNS topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.info_alerts[0].arn : null
}

output "sns_topic_security_alerts_arn" {
  description = "ARN of the security alerts SNS topic"
  value       = var.enable_sns_notifications ? aws_sns_topic.security_alerts[0].arn : null
}

# Message Formatting
output "message_formatter_function_name" {
  description = "Name of the Lambda function used for message formatting"
  value       = var.enable_sns_notifications && var.enable_message_formatting ? aws_lambda_function.message_formatter[0].function_name : null
}

output "notification_dlq_url" {
  description = "URL of the SQS dead letter queue for failed notifications"
  value       = var.enable_sns_notifications ? aws_sqs_queue.notification_dlq[0].url : null
}

# EC2 Alarms
output "ec2_alarm_names" {
  description = "List of EC2 CloudWatch alarm names"
  value = var.enable_ec2_monitoring ? [
    aws_cloudwatch_metric_alarm.ec2_high_cpu[0].alarm_name,
    aws_cloudwatch_metric_alarm.ec2_critical_cpu[0].alarm_name,
    aws_cloudwatch_metric_alarm.ec2_low_cpu[0].alarm_name,
    aws_cloudwatch_metric_alarm.ec2_instance_status_check[0].alarm_name,
    aws_cloudwatch_metric_alarm.ec2_system_status_check[0].alarm_name,
    aws_cloudwatch_metric_alarm.ec2_high_network_in[0].alarm_name,
    aws_cloudwatch_metric_alarm.ec2_high_network_out[0].alarm_name
  ] : []
}

# RDS Alarms
output "rds_alarm_names" {
  description = "List of RDS CloudWatch alarm names"
  value = var.enable_rds_monitoring ? [
    aws_cloudwatch_metric_alarm.rds_high_cpu[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_critical_cpu[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_high_connections[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_critical_connections[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_low_free_storage[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_critical_free_storage[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_high_read_latency[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_high_write_latency[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_low_read_iops[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_connection_failures[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_long_running_transactions[0].alarm_name,
    aws_cloudwatch_metric_alarm.rds_low_utilization[0].alarm_name
  ] : []
}

# ALB Alarms
output "alb_alarm_names" {
  description = "List of ALB CloudWatch alarm names"
  value = var.enable_alb_monitoring ? [
    aws_cloudwatch_metric_alarm.alb_high_response_time[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_critical_response_time[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_high_4xx_errors[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_high_5xx_errors[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_target_4xx_errors[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_target_5xx_errors[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_high_request_count[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_very_high_request_count[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_low_request_count[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_unhealthy_targets[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_low_healthy_targets[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_high_active_connections[0].alarm_name,
    aws_cloudwatch_metric_alarm.alb_high_new_connections[0].alarm_name
  ] : []
}

# Alarm Summary
output "monitoring_summary" {
  description = "Summary of monitoring resources created"
  value = {
    log_groups_created     = var.enable_log_groups ? length(local.log_groups) : 0
    sns_topics_created     = var.enable_sns_notifications ? 4 : 0
    ec2_alarms_created     = var.enable_ec2_monitoring ? 7 : 0
    rds_alarms_created     = var.enable_rds_monitoring ? 12 : 0
    alb_alarms_created     = var.enable_alb_monitoring ? 13 : 0
    email_notifications    = var.notification_email != "" ? true : false
    sms_notifications      = var.notification_phone != "" ? true : false
    slack_integration      = var.slack_webhook_url != "" ? true : false
    teams_integration      = var.teams_webhook_url != "" ? true : false
    custom_webhook         = var.custom_webhook_url != "" ? true : false
    message_formatting     = var.enable_message_formatting
    detailed_monitoring    = var.enable_detailed_monitoring
  }
}