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
      prefix = "" # Apply to all objects
    }

    expiration {
      days = 90 # Delete logs older than 90 days
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}



# Origin Access Identity for S3
resource "aws_cloudfront_origin_access_identity" "static_assets" {
  comment = "CloudFront access to S3 static assets"
}
resource "aws_cloudfront_distribution" "static_assets" {
  origin {
    domain_name = aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.static_assets.id}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_assets.cloudfront_access_identity_path
    }
  }
  enabled             = true         #Activates the distribution
  is_ipv6_enabled     = true         #Allows IPv6 connections for better global compatibility
  default_root_object = "index.html" #When someone visits the root URL, serve this file
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.static_assets.id}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }
  #Limits edge locations to reduce costs (100 = cheapest tier covering major regions)
  price_class = "PriceClass_100" # US, Canada, Europe
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    #Uses AWS-provided SSL certificate (free, but uses CloudFront domain)
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cdn"
  }
}


#Grant CloudFront permission to read files from S3 bucket
resource "aws_s3_bucket_policy" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.static_assets.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_assets.arn}/*"
      }
    ]
  })
}
