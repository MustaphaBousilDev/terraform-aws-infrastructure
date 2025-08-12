terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Use networking module
module "networking" {
  source = "../../modules/networking"
  
  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr          = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

# Test S3 bucket
resource "aws_s3_bucket" "test" {
  bucket = "${var.project_name}-${var.environment}-test"
}