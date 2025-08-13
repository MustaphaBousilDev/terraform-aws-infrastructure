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
/*resource "aws_s3_bucket" "test" {
  bucket = "${var.project_name}-${var.environment}-test"
}*/

# Compute module
module "compute" {
  source = "../../modules/compute"
  
  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  public_subnet_ids   = module.networking.public_subnet_ids
  instance_type       = "t3.micro"
}


# Database module
module "database" {
  source = "../../modules/database"
  
  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  app_security_group_id  = module.compute.app_security_group_id
  db_password            = "MySecurePassword123!"
}

# Storage module
module "storage" {
  source = "../../modules/storage"
  
  project_name      = var.project_name
  environment       = var.environment
  enable_versioning = true
  enable_public_read = false
}

# Security module
module "security" {
  source = "../../modules/security"
  
  project_name           = var.project_name
  environment            = var.environment
  db_password            = "MySecurePassword123!"
  create_ssl_certificate = false
  domain_name            = ""
}