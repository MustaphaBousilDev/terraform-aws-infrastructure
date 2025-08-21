# Redis CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "redis_high_cpu" {
  count = var.enable_redis_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-redis-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Redis CPU utilization is high"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  
  dimensions = {
    CacheClusterId = var.redis_cluster_id
  }
}