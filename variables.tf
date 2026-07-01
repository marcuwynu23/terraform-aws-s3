variable "source_bucket_prefix" {
  description = "Prefix for the source S3 bucket name (random suffix appended)"
  type        = string
  default     = "my-unique-bucket-name-"
}

variable "logging_bucket_prefix" {
  description = "Prefix for the logging S3 bucket name (random suffix appended)"
  type        = string
  default     = "my-unique-logging-bucket-"
}

variable "bucket_acl" {
  description = "ACL for both S3 buckets"
  type        = string
  default     = "private"
}

variable "log_target_prefix" {
  description = "Prefix for log objects in the logging bucket"
  type        = string
  default     = "log/"
}
