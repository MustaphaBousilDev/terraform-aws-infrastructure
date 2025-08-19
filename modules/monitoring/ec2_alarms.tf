# =============================================================================
# CLOUDWATCH ALARMS FOR EC2 INSTANCES MONITORING
# =============================================================================
data "aws_instances" "auto_scaling_instances" {
  count = var.enable_ec2_monitoring ? 1 : 0
  
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [var.auto_scaling_group_name]
  }
  
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

# =============================================================================
# CPU UTILIZATION ALARMS
# =============================================================================

# High CPU Utilization Alarm (Critical)
resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  count = var.enable_ec2_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.ec2_cpu_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization for Auto Scaling Group: ${var.auto_scaling_group_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-high-cpu-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "performance"
    Severity    = "high"
    Purpose     = "Monitor EC2 CPU utilization across Auto Scaling Group"
  }
}

# Very High CPU Utilization Alarm (Critical - for immediate scaling)
resource "aws_cloudwatch_metric_alarm" "ec2_critical_cpu" {
  count = var.enable_ec2_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-ec2-critical-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1  # Trigger faster for critical alerts
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = var.ec2_cpu_threshold + 15  # 15% higher than regular threshold
  alarm_description   = "CRITICAL: Very high CPU utilization detected on Auto Scaling Group: ${var.auto_scaling_group_name}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-critical-cpu-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "performance"
    Severity    = "critical"
    Purpose     = "Monitor critical EC2 CPU utilization for immediate action"
  }
}

# Low CPU Utilization Alarm (for cost optimization)
resource "aws_cloudwatch_metric_alarm" "ec2_low_cpu" {
  count = var.enable_ec2_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-ec2-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 6  # 30 minutes of low usage
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 10  # 10% CPU utilization
  alarm_description   = "Low CPU utilization detected - consider downsizing for cost optimization"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.info_alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-low-cpu-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "cost-optimization"
    Severity    = "info"
    Purpose     = "Identify underutilized instances for cost optimization"
  }
}

# =============================================================================
# STATUS CHECK ALARMS (Instance and System Health)
# =============================================================================

# Instance Status Check Failed
resource "aws_cloudwatch_metric_alarm" "ec2_instance_status_check" {
  count = var.enable_ec2_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-ec2-instance-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = 60  # Check every minute
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Instance status check failed - instance may need to be recovered"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-instance-status-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "health"
    Severity    = "critical"
    Purpose     = "Monitor EC2 instance health status checks"
  }
}

# System Status Check Failed
resource "aws_cloudwatch_metric_alarm" "ec2_system_status_check" {
  count = var.enable_ec2_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-ec2-system-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = 60  # Check every minute
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "System status check failed - AWS infrastructure issue detected"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-system-status-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "health"
    Severity    = "critical"
    Purpose     = "Monitor EC2 system-level health status checks"
  }
}

# =============================================================================
# NETWORK PERFORMANCE ALARMS
# =============================================================================

# High Network In (Unusual incoming traffic)
resource "aws_cloudwatch_metric_alarm" "ec2_high_network_in" {
  count = var.enable_ec2_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-ec2-high-network-in"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 100000000  # 100 MB (adjust based on your normal traffic)
  alarm_description   = "High incoming network traffic detected - possible DDoS or traffic spike"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-high-network-in-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "network"
    Severity    = "medium"
    Purpose     = "Monitor unusual incoming network traffic patterns"
  }
}

# High Network Out (Unusual outgoing traffic)
resource "aws_cloudwatch_metric_alarm" "ec2_high_network_out" {
  count = var.enable_ec2_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-ec2-high-network-out"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "NetworkOut"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 100000000  # 100 MB
  alarm_description   = "High outgoing network traffic detected - possible data exfiltration or backup activity"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-high-network-out-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "network"
    Severity    = "medium"
    Purpose     = "Monitor unusual outgoing network traffic patterns"
  }
}

# =============================================================================
# DISK SPACE ALARMS (Requires CloudWatch Agent)
# =============================================================================

# Note: These alarms require the CloudWatch agent to be installed on EC2 instances
# The agent sends custom metrics about disk usage to CloudWatch

# High Disk Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ec2_high_disk_usage" {
  count = var.enable_ec2_monitoring && var.enable_detailed_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-ec2-high-disk-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 85  # 85% disk usage
  alarm_description   = "High disk usage detected - disk space running low"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
    device               = "/dev/xvda1"  # Root volume
    fstype               = "ext4"
    path                 = "/"
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-disk-usage-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "storage"
    Severity    = "high"
    Purpose     = "Monitor disk space utilization"
  }
}

# Critical Disk Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ec2_critical_disk_usage" {
  count = var.enable_ec2_monitoring && var.enable_detailed_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-ec2-critical-disk-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1  # Immediate alert for critical disk space
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 95  # 95% disk usage - critical!
  alarm_description   = "CRITICAL: Disk space critically low - immediate action required"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
    device               = "/dev/xvda1"
    fstype               = "ext4"
    path                 = "/"
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-critical-disk-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "storage"
    Severity    = "critical"
    Purpose     = "Monitor critical disk space utilization"
  }
}

# =============================================================================
# MEMORY UTILIZATION ALARMS (Requires CloudWatch Agent)
# =============================================================================

# High Memory Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ec2_high_memory" {
  count = var.enable_ec2_monitoring && var.enable_detailed_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-ec2-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.ec2_memory_threshold
  alarm_description   = "High memory utilization detected on EC2 instances"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    AutoScalingGroupName = var.auto_scaling_group_name
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-memory-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "performance"
    Severity    = "high"
    Purpose     = "Monitor EC2 memory utilization"
  }
}