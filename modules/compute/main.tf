# Security Group for Application Load Balancer
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}

# Security Group for EC2 instances
resource "aws_security_group" "app" {
  name_prefix = "${var.project_name}-${var.environment}-app-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-app-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-tg"
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd

              # Set database environment variables
              echo "PRIMARY_DB_HOST=${var.primary_db_endpoint}" >> /etc/environment
              echo "READ_REPLICA_DB_HOST=${var.read_replica_endpoint}" >> /etc/environment

              echo "<h1>Hello from ${var.project_name}-${var.environment}</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-instance"
    }
  }
}

# Data source for latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-${var.environment}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  # Enable instance refresh for zero-downtime deployments
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg"
    propagate_at_launch = false
  }
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}


# Autu Scaling Policy - Scale up (add more instances)
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-${var.environment}-scale-up"
  scaling_adjustment     = 1                  # Add 1 instance
  adjustment_type        = "ChangeInCapacity" # Change by exact number
  cooldown               = 300                # Wait 5 minutes before next scaling
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# Auto Scaling Plocy - Scale down (remove instances)
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-${var.environment}-scale-down"
  scaling_adjustment     = -1                 # Remove instance (negative)
  adjustment_type        = "ChangeInCapacity" # change by exact number
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# Add CPU Scale-Up Alarm
#--> Cloud WAtch Alarm - Scale UP when CPU is high
resource "aws_cloudwatch_metric_alarm" "cpu_scale_up" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-scale-up"
  comparison_operator = "GreaterThanThreshold"
  # evaluation_periods = 2 <- before triggering alarm , we need to check twice , and each check takes 5 minuts (means on ttoal 10 minut before trigger alarme)
  evaluation_periods = 2 #(How Many Checks Needed)
  metric_name        = "CPUUtilisation"
  namespace          = "AWS/EC2"
  period             = 300 # each 5 minute , cloudewatch check
  statistic          = "Average"
  threshold          = 70 # 70% CPU threshold
  alarm_description  = "Scale up when CPU > 70% for 10 minutes"
  # THIS IS THE KEY: Trigger the scale-up policy
  alarm_actions = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
  tags = {
    Name    = "${var.project_name}-${var.environment}-cpu-scale-up-alarm"
    Purpose = "auto-scaling-trigger"
  }
}


#CloudWAtch Alarm - Scale Down when CPU is low
resource "aws_cloudwatch_metric_alarm" "cpu_scale_down" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu-scale-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 4
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale down when CPU < 30% for 20 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
  tags = {
    Name    = "${var.project_name}-${var.environment}-cpu-scale-down-alarm"
    Purpose = "auto-scaling-trigger"
  }
}
