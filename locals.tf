locals {
  # Create a dedicated AWS Backup service role unless the caller passes an
  # existing role ARN.
  create_role = local.enabled && var.backup_role_arn == null

  # The role the backup selection assumes: the caller-supplied ARN wins,
  # otherwise the one created here.
  role_arn = var.backup_role_arn != null ? var.backup_role_arn : (
    local.create_role ? aws_iam_role.this[0].arn : null
  )

  # AWS-managed policies the backup role needs: one to take backups, one to
  # restore them. Partition is fixed to the standard commercial partition to
  # keep the for_each keys static (unknown values can't key a for_each).
  role_policy_arns = local.create_role ? {
    backup   = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
    restores = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  } : {}
}
