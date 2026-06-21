# Terraform AWS S3 Bucket with Server Access Logging

This project provisions two Amazon S3 buckets using Terraform:

- **Source Bucket** – the main bucket where your data lives
- **Logging Bucket** – a dedicated bucket to store access logs from the source bucket

It also configures **server access logging** so that all requests made to the source bucket are recorded in the logging bucket.

---

## Resources Created

- `aws_s3_bucket.my_s3_bucket` – Primary S3 bucket
- `aws_s3_bucket.logging_bucket` – Logging destination bucket
- `aws_s3_bucket_logging.my_bucket_logging` – Enables logging from source → logging bucket
- `random_id.bucket_id` – Ensures globally unique bucket names

---

## Configuration Details

### Provider

- AWS Region: `ap-southeast-1`

### Naming Strategy

S3 bucket names must be globally unique. This setup appends a random hex string:

```
my-unique-bucket-name-<random>
my-unique-logging-bucket-<random>
```

---

## Usage

### Prerequisites

Ensure you have the following installed and configured:

- Terraform (>= 1.0)
- AWS CLI
- An AWS account with sufficient permissions (S3, IAM)

Verify installations:

```bash
terraform -v
aws --version
```

### Configure AWS Credentials

Run:

```bash
aws configure
```

Provide:

- AWS Access Key ID
- AWS Secret Access Key
- Default region (use `ap-southeast-1` or match the Terraform config)
- Output format (e.g., `json`)

Alternatively, use environment variables:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-southeast-1"
```

### Initialize Terraform

```bash
terraform init
```

This downloads required providers (AWS, random).

### Validate Configuration (optional but recommended)

```bash
terraform validate
```

### Preview Changes

```bash
terraform plan
```

This shows what resources will be created.

### Apply Configuration (Provision S3 Buckets)

```bash
terraform apply
```

Type `yes` when prompted.

Terraform will:

- Generate a unique suffix
- Create the source S3 bucket
- Create the logging bucket
- Enable access logging

### Verify in AWS

After apply completes:

- Go to AWS Console → S3
- You should see both buckets created
- Check Properties → Server access logging in the source bucket

### Re-run Safely

Terraform is idempotent:

```bash
terraform apply
```

Running again will not recreate resources unless changes are made.

## Outputs

After deployment, Terraform will output:

- **source_bucket_name** – Name of the main S3 bucket
- **logging_bucket_name** – Name of the logging bucket
- **source_bucket_url** – S3 URI of the main bucket
- **logging_bucket_url** – S3 URI of the logging bucket

Example:

```
source_bucket_name = "my-unique-bucket-name-abc123"
logging_bucket_name = "my-unique-logging-bucket-abc123"
source_bucket_url = "s3://my-unique-bucket-name-abc123"
logging_bucket_url = "s3://my-unique-logging-bucket-abc123"
```

---

## Usage as a Module

Reference this repository as a Terraform module in your own configurations:

```hcl
module "s3_buckets" {
  source = "github.com/marcuwynu23/terraform-aws-s3?ref=main"
}
```

Then use the outputs in your configuration:

```hcl
# Example: reference the bucket names in another resource
resource "aws_s3_bucket_policy" "source_policy" {
  bucket = module.s3_buckets.source_bucket_name
  # ...
}
```

All outputs documented below are available when using this as a module.

---

## Permissions & Notes

- Both buckets are created with `private` ACL
- Ensure your AWS credentials are configured (`aws configure` or environment variables)
- The logging bucket must allow write access from the source bucket (handled implicitly by AWS when logging is enabled, but may require explicit policies in stricter setups)

---

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

---

## Best Practices

- Do **not** use the same bucket for both storage and logging
- Use lifecycle policies to manage log retention
- Consider enabling versioning for critical data
- Restrict bucket access using IAM policies instead of ACLs when possible

---

## File Structure

```
.
├── main.tf
└── README.md
```

---

## Summary

This setup provides a clean and production-ready pattern for:

- Secure S3 storage
- Centralized access logging
- Globally unique resource naming

You can extend this by adding:

- Bucket policies
- Encryption (SSE-S3 or SSE-KMS)
- Lifecycle rules for log rotation

---

## Troubleshooting

**Bucket name already exists**

- Rare but possible: rerun `terraform apply` to regenerate the random ID

**Access denied errors**

- Verify AWS credentials and IAM permissions

**Logging not appearing**

- Logs may take time to be delivered (usually minutes)

---

## License

This project is provided as-is for learning and infrastructure setup purposes.
