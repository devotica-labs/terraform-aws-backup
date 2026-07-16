output "vault_arn" {
  description = "ARN of the backup vault."
  value       = module.backup.vault_arn
}

output "plan_id" {
  description = "ID of the backup plan."
  value       = module.backup.plan_id
}

output "role_arn" {
  description = "ARN of the AWS Backup service role."
  value       = module.backup.role_arn
}
