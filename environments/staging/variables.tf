variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "AWS Instance Type"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraformawsinfrastructure"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"  # ← Only change this default
}