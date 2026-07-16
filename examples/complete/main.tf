# ---------------------------------------------------------------------------
# Provider block — CI-friendly skip flags + non-AWS-shaped placeholder creds.
# ---------------------------------------------------------------------------
provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "not-a-real-aws-key"
  secret_key                  = "not-a-real-aws-secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# A compliance-grade backup for the payments platform: multiple tiered rules
# (daily / weekly / monthly with cold storage), explicit resource ARNs, a
# customer-managed KMS key, and a WORM vault lock so recovery points are
# immutable for the retention window.
module "backup" {
  source = "../.."

  namespace = "dvtca"
  stage     = "prod"
  name      = "payments"

  # Customer-managed key instead of the AWS-managed aws/backup key.
  kms_key_arn = "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"

  # Tiered retention. Weekly/monthly tier surplus recovery points into cold
  # storage before deletion (cold_storage_after must be >= 90 days before
  # delete_after per AWS Backup).
  rules = [
    {
      name              = "daily"
      schedule          = "cron(0 5 * * ? *)"
      start_window      = 60
      completion_window = 360
      delete_after      = 35
    },
    {
      name               = "weekly"
      schedule           = "cron(0 5 ? * 1 *)"
      cold_storage_after = 30
      delete_after       = 365
    },
    {
      name               = "monthly"
      schedule           = "cron(0 5 1 * ? *)"
      cold_storage_after = 90
      delete_after       = 2555
    },
  ]

  # Explicit resource ARNs instead of tag-based selection.
  selection_resource_arns = [
    "arn:aws:rds:ap-south-1:111122223333:db:payments-primary",
    "arn:aws:dynamodb:ap-south-1:111122223333:table/payments-ledger",
  ]

  # Compliance vault lock (WORM): recovery points can't be deleted before 35
  # days; the lock itself becomes immutable after 3 days.
  vault_lock = {
    min_retention_days  = 35
    max_retention_days  = 3650
    changeable_for_days = 3
  }

  tags = {
    Environment = "prod"
    Project     = "terraform-aws-backup"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-backup"
  }
}
