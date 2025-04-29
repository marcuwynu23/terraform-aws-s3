# Provider Configuration
provider "aws" {
  region = "ap-southeast-1"  # Specify the AWS region
}

# Generate a unique ID for the S3 bucket name
resource "random_id" "bucket_id" {
  byte_length = 8  # Length of the generated ID
}

# Create the S3 Bucket (Source)
resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "my-unique-bucket-name-${random_id.bucket_id.hex}"
  acl    = "private"
  tags = {
    Name        = "MyS3Bucket"
    Environment = "Production"
  }
}

# Create the Logging Bucket (Target)
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "my-unique-logging-bucket-${random_id.bucket_id.hex}"  # Ensure the name is unique
  acl    = "private"
  tags = {
    Name        = "LoggingBucket"
    Environment = "Production"
  }
}

# Set up S3 Bucket Logging (new method)
resource "aws_s3_bucket_logging" "my_bucket_logging" {
  bucket        = aws_s3_bucket.my_s3_bucket.bucket
  target_bucket = aws_s3_bucket.logging_bucket.bucket
  target_prefix = "log/"
}

# Output: S3 Bucket Name (Source)
output "source_bucket_name" {
  value = aws_s3_bucket.my_s3_bucket.bucket
  description = "The name of the source S3 bucket."
}

# Output: Logging Bucket Name
output "logging_bucket_name" {
  value = aws_s3_bucket.logging_bucket.bucket
  description = "The name of the S3 bucket used for logging."
}

# Output: S3 Bucket URL (can be used in API)
output "source_bucket_url" {
  value = "s3://${aws_s3_bucket.my_s3_bucket.bucket}"
  description = "The URL of the source S3 bucket."
}

# Output: Logging Bucket URL (can be used in API)
output "logging_bucket_url" {
  value = "s3://${aws_s3_bucket.logging_bucket.bucket}"
  description = "The URL of the logging S3 bucket."
}
