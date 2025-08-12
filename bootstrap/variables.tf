variable "aws_region" {
  description = "The aws region where resources will be created"
  type = string
  default = "us-east-1"

  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format: us-west-2, eu-west-1, etc."
  }
}

variable "project_name" {
  description = "Name of the project - used for naming resources"
  type        = string
  
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
  
  validation {
    condition = length(var.project_name) >= 3 && length(var.project_name) <= 40
    error_message = "Project name must be between 3 and 20 characters."
  }
}
