output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "public_route_table_id" {
  description = "ID of public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of private route tables"
  value       = aws_route_table.private[*].id
}

output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "cloudwatch_endpoint_id" {
  description = "ID of the CloudWatch VPC endpoint"
  value       = var.enable_interface_endpoints ? aws_vpc_endpoint.cloudwatch[0].id : null
}

output "ec2_endpoint_id" {
  description = "ID of the EC2 VPC endpoint"
  value       = var.enable_interface_endpoints ? aws_vpc_endpoint.ec2[0].id : null
}

output "secretsmanager_endpoint_id" {
  description = "ID of the Secrets Manager VPC endpoint"
  value       = var.enable_interface_endpoints ? aws_vpc_endpoint.secretsmanager[0].id : null
}

output "vpc_endpoints_summary" {
  description = "Summary of created VPC endpoints"
  value = {
    gateway_endpoints = {
      s3_enabled       = true
      dynamodb_enabled = true
    }
    interface_endpoints = var.enable_interface_endpoints ? {
      cloudwatch_enabled     = true
      ec2_enabled           = true
      secretsmanager_enabled = true
      logs_enabled          = true
      rds_enabled           = var.enable_rds_endpoint
    } : {}
  }
}