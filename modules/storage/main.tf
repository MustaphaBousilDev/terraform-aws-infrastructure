# Random suffix for unique bucket names
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Main application bucket for user uploads
resource "aws_s3_bucket" "app_storage" {
  bucket = "${var.project_name}-${var.environment}-app-${random_string.bucket_suffix.result}"

  tags = {
    Name    = "${var.project_name}-${var.environment}-app-storage"
    Purpose = "application-files"
  }
}

# Static assets bucket (CSS, JS, images)
resource "aws_s3_bucket" "static_assets" {
  bucket = "${var.project_name}-${var.environment}-static-${random_string.bucket_suffix.result}"

  tags = {
    Name    = "${var.project_name}-${var.environment}-static-assets"
    Purpose = "static-website-files"
  }
}

# Logs bucket for application logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-${var.environment}-logs-${random_string.bucket_suffix.result}"

  tags = {
    Name    = "${var.project_name}-${var.environment}-logs"
    Purpose = "application-logs"
  }
}

# Versioning for application bucket
resource "aws_s3_bucket_versioning" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Encryption for application bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public access block for application bucket (private by default)
resource "aws_s3_bucket_public_access_block" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Static assets bucket configuration (can be public for CDN)
resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = !var.enable_public_read
  block_public_policy     = !var.enable_public_read
  ignore_public_acls      = !var.enable_public_read
  restrict_public_buckets = !var.enable_public_read
}

# Lifecycle rule for logs bucket (delete old logs)
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "log_retention"
    status = "Enabled"

    filter {
      prefix = ""  # Apply to all objects
    }

    expiration {
      days = 90  # Delete logs older than 90 days
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}