output "vault_arn" {
  description = "ARN of the backup vault."
  value       = module.backup.vault_arn
}

output "vault_name" {
  description = "Name of the backup vault."
  value       = module.backup.vault_name
}

output "plan_arn" {
  description = "ARN of the backup plan."
  value       = module.backup.plan_arn
}

output "role_arn" {
  description = "ARN of the AWS Backup service role."
  value       = module.backup.role_arn
}
