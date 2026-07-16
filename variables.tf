# ---------------------------------------------------------------------------
# Vault
# ---------------------------------------------------------------------------
variable "kms_key_arn" {
  type        = string
  description = "Customer-managed KMS key ARN encrypting the backup vault. Null uses the AWS-managed aws/backup key. Recovery points are always encrypted either way."
  default     = null

  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:aws[a-z-]*:kms:", var.kms_key_arn))
    error_message = "kms_key_arn must be a KMS ARN (arn:aws*:kms:...) or null."
  }
}

variable "vault_lock" {
  type = object({
    min_retention_days  = number
    max_retention_days  = number
    changeable_for_days = number
  })
  description = "Enable AWS Backup Vault Lock (compliance mode / WORM) with the given retention window. Null (default) leaves the vault unlocked. Once changeable_for_days elapses the lock is immutable and recovery points cannot be deleted before min_retention_days."
  default     = null

  validation {
    condition     = var.vault_lock == null || try(var.vault_lock.min_retention_days >= 1 && var.vault_lock.max_retention_days >= var.vault_lock.min_retention_days, false)
    error_message = "vault_lock.min_retention_days must be >= 1 and <= max_retention_days."
  }
}

# ---------------------------------------------------------------------------
# Plan rules
# ---------------------------------------------------------------------------
variable "rules" {
  type = list(object({
    name               = string
    schedule           = string
    start_window       = optional(number, 60)
    completion_window  = optional(number, 360)
    cold_storage_after = optional(number)
    delete_after       = optional(number, 35)
  }))
  description = "Backup plan rules. Each rule is a scheduled job: name, a cron/rate schedule, optional start/completion windows (minutes), optional cold_storage_after (days, null = warm only), and delete_after (days retention). Default is a single daily rule with 35-day retention."
  default = [{
    name     = "daily"
    schedule = "cron(0 5 * * ? *)"
  }]

  validation {
    condition     = length(var.rules) > 0
    error_message = "At least one backup rule is required."
  }

  validation {
    condition     = length(var.rules) == length(distinct([for r in var.rules : r.name]))
    error_message = "Each rule name must be unique."
  }
}

# ---------------------------------------------------------------------------
# Resource selection
# ---------------------------------------------------------------------------
variable "selection_resource_arns" {
  type        = list(string)
  description = "Explicit resource ARNs to include in the backup plan (e.g. RDS, EBS, DynamoDB, EFS). Empty relies on selection_tags for tag-based selection."
  default     = []
}

variable "selection_tags" {
  type        = map(string)
  description = "Tag-based selection: every resource carrying each key=value tag (STRINGEQUALS) is backed up. Empty relies on selection_resource_arns."
  default     = {}
}

# ---------------------------------------------------------------------------
# Service role
# ---------------------------------------------------------------------------
variable "backup_role_arn" {
  type        = string
  description = "Existing IAM role ARN for AWS Backup to assume. Null (default) creates a dedicated role trusting backup.amazonaws.com with the AWS-managed backup + restore policies attached."
  default     = null

  validation {
    condition     = var.backup_role_arn == null || can(regex("^arn:aws[a-z-]*:iam::", var.backup_role_arn))
    error_message = "backup_role_arn must be an IAM role ARN (arn:aws*:iam::...) or null."
  }
}
