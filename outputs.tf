output "vault_arn" {
  description = "ARN of the backup vault."
  value       = try(aws_backup_vault.this[0].arn, null)
}

output "vault_name" {
  description = "Name of the backup vault."
  value       = try(aws_backup_vault.this[0].name, null)
}

output "plan_id" {
  description = "ID of the backup plan."
  value       = try(aws_backup_plan.this[0].id, null)
}

output "plan_arn" {
  description = "ARN of the backup plan."
  value       = try(aws_backup_plan.this[0].arn, null)
}

output "role_arn" {
  description = "ARN of the IAM role AWS Backup assumes (created here or the supplied backup_role_arn)."
  value       = local.role_arn
}
