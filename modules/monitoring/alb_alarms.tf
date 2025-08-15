# =============================================================================
# CLOUDWATCH ALARMS FOR APPLICATION LOAD BALANCER MONITORING
# =============================================================================

# Data source to extract load balancer name from ARN
locals {
  # Extract ALB name from ARN format: arn:aws:elasticloadbalancing:region:account:loadbalancer/app/name/id
  alb_name = var.enable_alb_monitoring ? split("/", var.load_balancer_arn)[2] : ""
  # Extract target group name from ARN
  target_group_name = var.enable_alb_monitoring ? split("/", var.target_group_arn)[1] : ""
}

# =============================================================================
# RESPONSE TIME ALARMS
# =============================================================================

# High Response Time Alarm
resource "aws_cloudwatch_metric_alarm" "alb_high_response_time" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.alb_response_time_threshold
  alarm_description   = "High response time detected on ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-response-time-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "load-balancer-performance"
    Severity    = "medium"
    Purpose     = "Monitor ALB response time for performance issues"
  }
}

# Critical Response Time Alarm
resource "aws_cloudwatch_metric_alarm" "alb_critical_response_time" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-critical-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1  # Immediate alert for critical response times
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.alb_response_time_threshold * 3  # 3x normal threshold
  alarm_description   = "CRITICAL: Very high response time detected on ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-critical-response-time-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "load-balancer-performance"
    Severity    = "critical"
    Purpose     = "Monitor critical ALB response time requiring immediate attention"
  }
}

# =============================================================================
# ERROR RATE ALARMS
# =============================================================================

# High 4xx Error Rate (Client Errors)
resource "aws_cloudwatch_metric_alarm" "alb_high_4xx_errors" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-high-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = 50  # More than 50 4xx errors in 5 minutes
  alarm_description   = "High rate of 4xx client errors detected on ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-4xx-errors-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "load-balancer-errors"
    Severity    = "medium"
    Purpose     = "Monitor client-side errors (4xx) for potential issues"
  }
}

# High 5xx Error Rate (Server Errors)
resource "aws_cloudwatch_metric_alarm" "alb_high_5xx_errors" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2  # Quick response to server errors
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = 10  # More than 10 5xx errors in 5 minutes
  alarm_description   = "High rate of 5xx server errors detected on ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-5xx-errors-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "load-balancer-errors"
    Severity    = "critical"
    Purpose     = "Monitor server-side errors (5xx) indicating backend issues"
  }
}

# High Target 4xx Error Rate (Backend Application Errors)
resource "aws_cloudwatch_metric_alarm" "alb_target_4xx_errors" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-target-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = 100  # More than 100 target 4xx errors in 5 minutes
  alarm_description   = "High rate of target 4xx errors from backend servers: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-target-4xx-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "application errors"
    Severity    = "medium"
    Purpose     = "Monitor application level 4xx errors from backend servers"
  }
}

# High Target 5xx Error Rate (Backend Server Errors)
resource "aws_cloudwatch_metric_alarm" "alb_target_5xx_errors" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-target-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1  # Immediate alert for backend server errors
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = 5  # More than 5 target 5xx errors in 5 minutes
  alarm_description   = "CRITICAL: High rate of target 5xx errors from backend servers: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-target-5xx-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "application-errors"
    Severity    = "critical"
    Purpose     = "Monitor critical application-level 5xx errors from backend servers"
  }
}

# =============================================================================
# REQUEST COUNT AND TRAFFIC ALARMS
# =============================================================================

# High Request Count (Traffic Spike)
resource "aws_cloudwatch_metric_alarm" "alb_high_request_count" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-high-request-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = 1000  # More than 1000 requests in 5 minutes
  alarm_description   = "High request count detected - possible traffic spike on ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-high-requests-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "traffic-volume"
    Severity    = "medium"
    Purpose     = "Monitor traffic spikes for capacity planning"
  }
}

# Very High Request Count (Potential DDoS)
resource "aws_cloudwatch_metric_alarm" "alb_very_high_request_count" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-very-high-request-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1  # Immediate alert for potential attacks
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5000  # More than 5000 requests in 5 minutes
  alarm_description   = "CRITICAL: Very high request count - possible DDoS attack on ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-very-high-requests-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "security-traffic"
    Severity    = "critical"
    Purpose     = "Monitor potential DDoS attacks or unusual traffic patterns"
  }
}

# Low Request Count (Potential Connectivity Issues)
resource "aws_cloudwatch_metric_alarm" "alb_low_request_count" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-low-request-count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 6  # 30 minutes of low traffic
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = 5  # Less than 5 requests in 5 minutes
  alarm_description   = "Very low request count - possible connectivity or DNS issues for ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.info_alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-low-requests-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "connectivity"
    Severity    = "info"
    Purpose     = "Monitor unusually low traffic indicating potential issues"
  }
}

# =============================================================================
# TARGET HEALTH ALARMS
# =============================================================================

# Unhealthy Target Count
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-unhealthy-targets"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0  # Any unhealthy targets
  alarm_description   = "Unhealthy targets detected in target group for ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
    TargetGroup  = split("targetgroup/", var.target_group_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-unhealthy-targets-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "target-health"
    Severity    = "critical"
    Purpose     = "Monitor backend server health and availability"
  }
}

# Low Healthy Target Count
resource "aws_cloudwatch_metric_alarm" "alb_low_healthy_targets" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-low-healthy-targets"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 1  # Less than 1 healthy target on average
  alarm_description   = "Low number of healthy targets in target group for ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
    TargetGroup  = split("targetgroup/", var.target_group_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-low-healthy-targets-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "target-health"
    Severity    = "critical"
    Purpose     = "Monitor minimum number of healthy backend servers"
  }
}

# =============================================================================
# CONNECTION AND NETWORK ALARMS
# =============================================================================

# High Active Connection Count
resource "aws_cloudwatch_metric_alarm" "alb_high_active_connections" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-high-active-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "ActiveConnectionCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 500  # More than 500 active connections
  alarm_description   = "High number of active connections on ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-active-connections-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "connection-load"
    Severity    = "medium"
    Purpose     = "Monitor concurrent connection load on load balancer"
  }
}

# High New Connection Rate
resource "aws_cloudwatch_metric_alarm" "alb_high_new_connections" {
  count = var.enable_alb_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-alb-high-new-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "NewConnectionCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Sum"
  threshold           = 1000  # More than 1000 new connections in 5 minutes
  alarm_description   = "High rate of new connections on ALB: ${local.alb_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    LoadBalancer = split("loadbalancer/", var.load_balancer_arn)[1]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-new-connections-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "connection-rate"
    Severity    = "medium"
    Purpose     = "Monitor rate of new connections for capacity planning"
  }
}