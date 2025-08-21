resource "aws_cloudwatch_metric_alarm" "cloudfront_high_error_rate" {
    count = var.enable_cloudfront_monitoring ? 1 : 0

    alarm_name = "${var.project_name}-${var.environment}-cloudfront-high-error-rate"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 2
    metric_name         = "ErrorRate"
    namespace           = "AWS/CloudFront"
    period              = 300
    statistic           = "Average"
    threshold           = 5  # 5% error rate
    alarm_description   = "CloudFront error rate is high"
    alarm_actions = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
    dimensions = {
        DistributionId = var.cloudfront_distribution_id
    }
}

resource "aws_cloudwatch_metric_alarm" "cloudfront_low_cache_hit_rate" {
    count = var.enable_cloudfront_monitoring ? 1 : 0

    alarm_name          = "${var.project_name}-${var.environment}-cloudfront-low-cache-hit-rate"
    comparison_operator = "LessThanThreshold"
    evaluation_periods  = 3
    metric_name         = "CacheHitRate"
    namespace           = "AWS/CloudFront"
    period              = 300
    statistic           = "Average"
    threshold           = 70  # 70% cache hit rate
    alarm_description   = "CloudFront cache hit rate is low"
    alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
    dimensions = {
        DistributionId = var.cloudfront_distribution_id
    }
}
