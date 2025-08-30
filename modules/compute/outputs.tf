output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "certificate_arn" {
  description = "ARN of the SSL certificate"
  value       = var.enable_ssl ? aws_acm_certificate.main[0].arn : null
}

output "https_endpoint" {
  description = "HTTPS endpoint URL"
  value       = var.enable_ssl ? "https://${var.domain_name}" : "http://${aws_lb.main.dns_name}"
}

output "certificate_validation_records" {
  description = "DNS validation records for certificate"
  value       = var.enable_ssl ? aws_acm_certificate.main[0].domain_validation_options : []
}