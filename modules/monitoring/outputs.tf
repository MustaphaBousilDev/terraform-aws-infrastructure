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

# Alarm Summary
output "monitoring_summary" {
  description = "Summary of monitoring resources created"
  value = {
    log_groups_created     = var.enable_log_groups ? length(local.log_groups) : 0
    sns_topics_created     = var.enable_sns_notifications ? 3 : 0
    ec2_alarms_created     = var.enable_ec2_monitoring ? 7 : 0
    email_notifications    = var.notification_email != "" ? true : false
    sms_notifications      = var.notification_phone != "" ? true : false
    detailed_monitoring    = var.enable_detailed_monitoring
  }
}