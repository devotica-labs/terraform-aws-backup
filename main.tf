# AWS Backup: a KMS-encrypted vault, a plan with one or more scheduled rules, a
# resource/tag selection, and (by default) a dedicated service role. Fintech
# defaults: encrypted vault, 35-day retention, optional cold storage, and an
# optional compliance vault lock.

resource "aws_backup_vault" "this" {
  count = local.enabled ? 1 : 0

  name = local.id
  # AWS Backup vaults are always encrypted; kms_key_arn selects a customer-managed
  # key. Null uses the AWS-managed aws/backup key.
  kms_key_arn = var.kms_key_arn

  tags = local.tags
}

# Compliance vault lock (WORM). Once locked past changeable_for_days the
# retention windows are immutable — recovery points can't be deleted early. Only
# created when var.vault_lock is set.
resource "aws_backup_vault_lock_configuration" "this" {
  count = local.enabled && var.vault_lock != null ? 1 : 0

  backup_vault_name   = aws_backup_vault.this[0].name
  min_retention_days  = var.vault_lock.min_retention_days
  max_retention_days  = var.vault_lock.max_retention_days
  changeable_for_days = var.vault_lock.changeable_for_days
}

resource "aws_backup_plan" "this" {
  count = local.enabled ? 1 : 0

  name = local.id

  dynamic "rule" {
    for_each = { for r in var.rules : r.name => r }

    content {
      rule_name           = rule.value.name
      target_vault_name   = aws_backup_vault.this[0].name
      schedule            = rule.value.schedule
      start_window        = rule.value.start_window
      completion_window   = rule.value.completion_window
      recovery_point_tags = local.tags

      lifecycle {
        # Null cold_storage_after keeps recovery points in warm storage only.
        cold_storage_after = rule.value.cold_storage_after
        delete_after       = rule.value.delete_after
      }
    }
  }

  tags = local.tags
}

resource "aws_backup_selection" "this" {
  count = local.enabled ? 1 : 0

  name         = local.id
  iam_role_arn = local.role_arn
  plan_id      = aws_backup_plan.this[0].id

  # Explicit resource ARNs to back up. Empty selects by tag only.
  resources = var.selection_resource_arns

  # Tag-based selection: back up every resource carrying each key=value tag.
  dynamic "selection_tag" {
    for_each = var.selection_tags

    content {
      type  = "STRINGEQUALS"
      key   = selection_tag.key
      value = selection_tag.value
    }
  }
}

# ---------------------------------------------------------------------------
# Service role — created unless the caller supplies backup_role_arn.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = local.create_role ? 1 : 0

  name               = "${local.id}-backup"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.role_policy_arns

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
