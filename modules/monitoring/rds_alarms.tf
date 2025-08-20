# =============================================================================
# CLOUDWATCH ALARMS FOR RDS DATABASE MONITORING
# =============================================================================

# =============================================================================
# CPU UTILIZATION ALARMS
# =============================================================================

# High Database CPU Utilization
resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.rds_cpu_threshold
  alarm_description   = "RDS CPU utilization is high for database: ${var.db_instance_identifier}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-high-cpu-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-performance"
    Severity    = "high"
    Purpose     = "Monitor RDS CPU utilization for performance issues"
  }
}

# Critical Database CPU Utilization
resource "aws_cloudwatch_metric_alarm" "rds_critical_cpu" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-critical-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1  # Immediate alert for critical database issues
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 90  # Fixed critical threshold
  alarm_description   = "CRITICAL: RDS CPU utilization is critically high for database: ${var.db_instance_identifier}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-critical-cpu-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-performance"
    Severity    = "critical"
    Purpose     = "Monitor critical RDS CPU utilization requiring immediate attention"
  }
}

# =============================================================================
# DATABASE CONNECTION ALARMS
# =============================================================================

# High Database Connections
resource "aws_cloudwatch_metric_alarm" "rds_high_connections" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.rds_connection_threshold
  alarm_description   = "High number of database connections for: ${var.db_instance_identifier}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-connections-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-connections"
    Severity    = "medium"
    Purpose     = "Monitor RDS connection count to prevent connection exhaustion"
  }
}

# Critical Database Connections (Near Connection Limit)
resource "aws_cloudwatch_metric_alarm" "rds_critical_connections" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-critical-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Maximum"
  threshold           = var.rds_connection_threshold * 1.5  # 150% of normal threshold
  alarm_description   = "CRITICAL: Database connection count approaching limit for: ${var.db_instance_identifier}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-critical-connections-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-connections"
    Severity    = "critical"
    Purpose     = "Monitor critical RDS connection levels near database limits"
  }
}

# =============================================================================
# STORAGE AND DISK SPACE ALARMS
# =============================================================================

# Low Free Storage Space
resource "aws_cloudwatch_metric_alarm" "rds_low_free_storage" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-low-free-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.rds_free_space_threshold  # Default: 2GB in bytes
  alarm_description   = "Low free storage space on database: ${var.db_instance_identifier}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-storage-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-storage"
    Severity    = "high"
    Purpose     = "Monitor RDS free storage space to prevent storage exhaustion"
  }
}

# Critical Free Storage Space
resource "aws_cloudwatch_metric_alarm" "rds_critical_free_storage" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-critical-free-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_free_space_threshold / 2  # Half of the warning threshold
  alarm_description   = "CRITICAL: Very low free storage space on database: ${var.db_instance_identifier}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "breaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-critical-storage-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-storage"
    Severity    = "critical"
    Purpose     = "Monitor critical RDS storage levels requiring immediate action"
  }
}

# =============================================================================
# DATABASE PERFORMANCE ALARMS
# =============================================================================

# High Read Latency
resource "aws_cloudwatch_metric_alarm" "rds_high_read_latency" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-high-read-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "ReadLatency"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 0.2  # 200ms read latency
  alarm_description   = "High read latency detected on database: ${var.db_instance_identifier}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-read-latency-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-performance"
    Severity    = "medium"
    Purpose     = "Monitor RDS read latency for performance optimization"
  }
}

# High Write Latency
resource "aws_cloudwatch_metric_alarm" "rds_high_write_latency" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-high-write-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "WriteLatency"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 0.2  # 200ms write latency
  alarm_description   = "High write latency detected on database: ${var.db_instance_identifier}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-write-latency-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-performance"
    Severity    = "medium"
    Purpose     = "Monitor RDS write latency for performance optimization"
  }
}

# Low Database Throughput (Read IOPS)
resource "aws_cloudwatch_metric_alarm" "rds_low_read_iops" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-low-read-iops"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 6  # 30 minutes of low activity
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 5  # Very low read operations
  alarm_description   = "Unusually low read IOPS - database may be underutilized or having connectivity issues"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.info_alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-low-iops-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-utilization"
    Severity    = "info"
    Purpose     = "Monitor unusually low database activity for optimization"
  }
}

# =============================================================================
# DATABASE AVAILABILITY AND CONNECTIVITY ALARMS
# =============================================================================

# Database Connection Failures
resource "aws_cloudwatch_metric_alarm" "rds_connection_failures" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "rds-connection-failures-${var.project_name}-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Database connection failures detected for: ${var.db_instance_identifier}"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.critical_alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-connection-failures-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-availability"
    Severity    = "critical"
    Purpose     = "Monitor RDS connection failures and availability issues"
  }
}

# =============================================================================
# DATABASE BACKUP AND MAINTENANCE ALARMS
# =============================================================================

# Long Running Transactions (MySQL specific)
resource "aws_cloudwatch_metric_alarm" "rds_long_running_transactions" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-long-transactions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"  # Proxy metric - would need custom metric for actual long transactions
  namespace           = "AWS/RDS"
  period              = 600  # 10 minutes
  statistic           = "Average"
  threshold           = var.rds_connection_threshold * 0.8  # 80% of connection threshold
  alarm_description   = "Potential long-running transactions detected - may indicate blocking queries"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-long-transactions-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "database-performance"
    Severity    = "medium"
    Purpose     = "Monitor potential long-running database transactions"
  }
}

# =============================================================================
# COST OPTIMIZATION ALARMS
# =============================================================================

# Consistently Low Database Utilization
resource "aws_cloudwatch_metric_alarm" "rds_low_utilization" {
  count = var.enable_rds_monitoring ? 1 : 0
  
  alarm_name          = "${var.project_name}-${var.environment}-rds-low-utilization"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 24  # 2 hours of low utilization
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = 10  # 10% CPU utilization
  alarm_description   = "Consistently low database utilization - consider downsizing for cost optimization"
  alarm_actions       = var.enable_sns_notifications ? [aws_sns_topic.info_alerts[0].arn] : []
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-low-utilization-alarm"
    Environment = var.environment
    Project     = var.project_name
    AlarmType   = "cost-optimization"
    Severity    = "info"
    Purpose     = "Identify underutilized RDS instances for cost optimization"
  }
}

# Read replica monitoring 
resource "aws_cloudwatch_metric_alarm" "read_replica_lag" {
  count = var.enable_rds_monitoring ? 1 : 0

  alarm_name = "${var.project_name}-${var.environment}-replica-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReplicaLag"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 30  # 30 seconds lag
  alarm_description   = "Read replica lag is high"
  dimensions = {
    DBInstanceIdentifier = "${var.project_name}-${var.environment}-db-replica"
  }
}