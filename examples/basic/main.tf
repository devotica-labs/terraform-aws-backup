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

# Uses local path during development.
# Change to Registry source after first release:
#   source  = "devotica-labs/backup/aws"
#   version = "~> 0.1"

module "backup" {
  source = "../.."

  # Vault / plan / selection / role name composes to: dvtca-sandbox-db
  namespace = "dvtca"
  stage     = "sandbox"
  name      = "db"

  # Tag-based selection: back up every resource tagged backup=daily.
  selection_tags = {
    backup = "daily"
  }

  # Fintech defaults cover the rest: KMS-encrypted vault (aws/backup key), a
  # single daily rule with 35-day retention, and a dedicated service role.

  tags = {
    Environment = "sandbox"
    Project     = "terraform-aws-backup"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-backup"
  }
}
