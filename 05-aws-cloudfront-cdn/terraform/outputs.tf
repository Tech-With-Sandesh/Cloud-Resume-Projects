output "cloudfront_domain" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (for cache invalidation)"
  value       = aws_cloudfront_distribution.main.id
}

output "s3_bucket_name" {
  description = "S3 origin bucket name"
  value       = aws_s3_bucket.origin.bucket
}

output "website_url" {
  description = "Full HTTPS URL of the website"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}
