# Output: S3 Bucket Name (Source)
output "source_bucket_name" {
  value       = aws_s3_bucket.my_s3_bucket.bucket
  description = "The name of the source S3 bucket."
}

# Output: Logging Bucket Name
output "logging_bucket_name" {
  value       = aws_s3_bucket.logging_bucket.bucket
  description = "The name of the S3 bucket used for logging."
}

# Output: S3 Bucket URL (can be used in API)
output "source_bucket_url" {
  value       = "s3://${aws_s3_bucket.my_s3_bucket.bucket}"
  description = "The URL of the source S3 bucket."
}

# Output: Logging Bucket URL (can be used in API)
output "logging_bucket_url" {
  value       = "s3://${aws_s3_bucket.logging_bucket.bucket}"
  description = "The URL of the logging S3 bucket."
}
