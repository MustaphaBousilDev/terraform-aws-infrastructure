variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of public subnets"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "primary_db_endpoint" {
  description = "Primary database endpoint for writes"
  type        = string
}

variable "read_replica_endpoint" {
  description = "Read replica endpoint for reads"
  type        = string
}

variable "asg_min_size" {
  description = "autoscaling group min instance"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "autoscaling group max instance"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "autoscaling group desired instance"
  type        = number
  default     = 2
}

variable "enable_ssl" {
  description = "Enable SSL/HTTPS on load balancer"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for SSL certificate"
  type        = string
  default     = ""
}

variable "health_check_path" {
  description = "Health check path for target group"
  type        = string
  default     = "/"
}