# WAF Web ACL for Application Load Balancer 
resource "aws_wafv2_web_acl" "main" {
    name = "${var.project_name}-${var.environment}-waf"
    scope = "REGIONAL"
    default_action {
      allow {}
    }

    # Rule 1: Block common SQL injection attacks
    rule {
        name = "AWSManagedRulesCommonRuleSet"
        priority = 1

        override_action {
          none {}
        }

        statement {
          managed_rule_group_statement {
            name = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"
          }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name                = "CommonRuleSetMetric"
            sampled_requests_enabled   = true
        }
    }

    # Rule 2: Block known bad inputs
    rule {
        name     = "AWSManagedRulesKnownBadInputsRuleSet"
        priority = 2
        override_action {
            none {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesKnownBadInputsRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name                = "KnownBadInputsMetric"
            sampled_requests_enabled   = true
        }
    }

    # Rule 3: Rate limiting
  rule {
    name     = "RateLimitRule"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.environment}-waf"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-waf"
  }
}

# Associate WAF with Application Load Balancer
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = var.load_balancer_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

