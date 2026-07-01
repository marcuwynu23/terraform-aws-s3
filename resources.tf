# Generate a unique ID for the S3 bucket name
resource "random_id" "bucket_id" {
  byte_length = 8 # Length of the generated ID
}

# Create the S3 Bucket (Source)
resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "${var.source_bucket_prefix}${random_id.bucket_id.hex}"
  tags = {
    Name        = "MyS3Bucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_acl" "my_s3_bucket_acl" {
  bucket = aws_s3_bucket.my_s3_bucket.id
  acl    = var.bucket_acl
}

# Create the Logging Bucket (Target)
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.logging_bucket_prefix}${random_id.bucket_id.hex}"
  tags = {
    Name        = "LoggingBucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = var.bucket_acl
}

# Set up S3 Bucket Logging (new method)
resource "aws_s3_bucket_logging" "my_bucket_logging" {
  bucket        = aws_s3_bucket.my_s3_bucket.bucket
  target_bucket = aws_s3_bucket.logging_bucket.bucket
  target_prefix = var.log_target_prefix
}