# Terraform AWS S3 Bucket with Server Access Logging

This project provisions two Amazon S3 buckets using Terraform:

- **Source Bucket** – the main bucket where your data lives
- **Logging Bucket** – a dedicated bucket to store access logs from the source bucket

It also configures **server access logging** so that all requests made to the source bucket are recorded in the logging bucket.

## Prerequisites

Ensure you have the following installed and configured:
- Terraform (>= 1.0)
- AWS CLI
- An AWS account with sufficient permissions (S3, IAM)

```bash
aws configure
```

Or use environment variables:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-southeast-1"
```

## Setup & Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Validate Configuration** (optional but recommended):
   ```bash
   terraform validate
   ```

3. **Preview Changes**:
   ```bash
   terraform plan
   ```

4. **Apply Configuration**:
   ```bash
   terraform apply
   ```

   Terraform will generate a unique suffix, create the source S3 bucket, create the logging bucket, and enable access logging.

5. **Verify in AWS**: Go to AWS Console → S3 to see both buckets. Check Properties → Server access logging in the source bucket.

## Usage as a Module

Reference this repository as a Terraform module in your own configurations:

```hcl
module "s3_buckets" {
  source = "github.com/marcuwynu23/terraform-aws-s3?ref=main"
}
```

Then use the outputs in your configuration:

```hcl
resource "aws_s3_bucket_policy" "source_policy" {
  bucket = module.s3_buckets.source_bucket_name
}
```

All outputs documented below are available when using this as a module.

## Variables

This module accepts no configurable variables. Bucket names are auto-generated with a random suffix.

## Outputs

| Output | Description |
|--------|-------------|
| `source_bucket_name` | Name of the main S3 bucket |
| `logging_bucket_name` | Name of the logging bucket |
| `source_bucket_url` | S3 URI of the main bucket |
| `logging_bucket_url` | S3 URI of the logging bucket |

## Resources Created

- `aws_s3_bucket.my_s3_bucket` – Primary S3 bucket
- `aws_s3_bucket.logging_bucket` – Logging destination bucket
- `aws_s3_bucket_logging.my_bucket_logging` – Enables logging from source → logging bucket
- `random_id.bucket_id` – Ensures globally unique bucket names

## Security Notes

- Both buckets are created with `private` ACL
- Ensure your AWS credentials are configured (`aws configure` or environment variables)
- The logging bucket must allow write access from the source bucket
- Do **not** use the same bucket for both storage and logging
- Use lifecycle policies to manage log retention
- Consider enabling versioning for critical data

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

## Remote State Management (S3 Backend)

This module uses AWS S3 as the Terraform backend for remote state management with DynamoDB for state locking.

### Create the Backend Resources

Run the following commands once per AWS account to create the bucket and lock table:

```bash
# Create S3 bucket for Terraform state
aws s3api create-bucket \
  --bucket your-terraform-state-bucket \
  --region ap-southeast-1 \
  --create-bucket-configuration LocationConstraint=ap-southeast-1

# Enable versioning on the bucket
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-southeast-1
```

### Configure the Backend

Create a `backend.tfvars` file:

```hcl
bucket         = "your-terraform-state-bucket"
key            = "s3/terraform.tfstate"
region         = "ap-southeast-1"
dynamodb_table = "terraform-state-lock"
encrypt        = true
```

Initialize with the backend config:

```bash
terraform init -backend-config="backend.tfvars"
```

### GitHub Actions CI/CD

Two workflows are available for automated deployment:

| Workflow | Description |
|----------|-------------|
| `terraform-cd-apply.yml` | Plan and provision infrastructure |
| `terraform-cd-destroy.yml` | Tear down infrastructure |

#### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key ID |
| `AWS_SECRET_ACCESS_KEY` | AWS secret access key |
| `TF_STATE_BUCKET` | S3 bucket name for Terraform state |
| `TF_STATE_REGION` | AWS region for the state bucket |
| `TF_STATE_LOCK_TABLE` | DynamoDB table for state locking |

## Troubleshooting

**Bucket name already exists**: Rare but possible — rerun `terraform apply` to regenerate the random ID.
**Access denied errors**: Verify AWS credentials and IAM permissions.
**Logging not appearing**: Logs may take time to be delivered (usually minutes).

## License

This project is provided as-is for learning and infrastructure setup purposes.
