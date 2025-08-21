output "app_storage_bucket_name" {
  description = "Name of the application storage bucket"
  value       = aws_s3_bucket.app_storage.bucket
}

output "app_storage_bucket_arn" {
  description = "ARN of the application storage bucket "
  value       = aws_s3_bucket.app_storage.arn
}

output "static_assets_bucket_name" {
  description = "Name of the static assets bucket"
  value       = aws_s3_bucket.static_assets.bucket
}

output "static_assets_bucket_arn" {
  description = "ARN of the static assets bucket"
  value       = aws_s3_bucket.static_assets.arn
}

output "logs_bucket_name" {
  description = "Name of the logs bucket"
  value       = aws_s3_bucket.logs.bucket
}

output "logs_bucket_arn" {
  description = "ARN of the logs bucket"
  value       = aws_s3_bucket.logs.arn
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.static_assets.id
}