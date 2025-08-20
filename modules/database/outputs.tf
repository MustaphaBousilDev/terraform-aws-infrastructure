output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "RDS instance address"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.database.id
}

output "db_subnet_group_name" {
  description = "Database subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "database_connection_string" {
  description = "Database connection string"
  value       = "mysql://${var.db_username}:${var.db_password}@${aws_db_instance.main.endpoint}/${var.db_name}"
  sensitive   = true
}

output "db_read_replica_endpoint" {
  description = "RDS read replica endpoint"
  value       = aws_db_instance.read_replica.endpoint
}

output "db_read_replica_port" {
  description = "RDS read replica port"
  value       = aws_db_instance.read_replica.port
}

output "db_read_replica_id" {
  description = "RDS read replica identifier"
  value       = aws_db_instance.read_replica.id
}

output "db_read_replica_endpoint" {
  description = "RDS read replica endpoint"
  value       = aws_db_instance.read_replica.endpoint
}

output "db_read_replica_port" {
  description = "RDS read replica port"
  value       = aws_db_instance.read_replica.port
}