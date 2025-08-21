variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "load_balancer_arn" {
  description = "Application Load Balancer ARN"
  type        = string
}