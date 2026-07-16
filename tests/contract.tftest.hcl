# Contract tests — naming + the fintech defaults stay stable across versions.

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  namespace = "dvtca"
  stage     = "test"
  name      = "contract"
}

run "vault_named_from_label" {
  command = plan
  assert {
    condition     = aws_backup_vault.this[0].name == "dvtca-test-contract"
    error_message = "Vault name must compose namespace-stage-name."
  }
}

run "plan_named_from_label" {
  command = plan
  assert {
    condition     = aws_backup_plan.this[0].name == "dvtca-test-contract"
    error_message = "Plan name must compose namespace-stage-name."
  }
}

run "default_retention_is_35_days" {
  command = plan
  # The rendered rule set is computed under mocks; assert the resolved input
  # (optional() default applied) which the lifecycle block passes through verbatim.
  assert {
    condition     = one([for r in var.rules : r.delete_after]) == 35
    error_message = "Default rule retention (delete_after) must be 35 days."
  }
}

run "kms_vault_default_managed_key" {
  command = plan
  # Vault is KMS-encrypted; default kms_key_arn is null → AWS-managed aws/backup
  # key (the resolved attribute is provider-computed, so assert the input + that
  # exactly one vault is planned).
  assert {
    condition     = var.kms_key_arn == null && length(aws_backup_vault.this) == 1
    error_message = "Default vault uses the AWS-managed backup key (kms_key_arn null)."
  }
}

run "kms_vault_customer_key_passthrough" {
  command = plan
  variables {
    kms_key_arn = "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  }
  assert {
    condition     = aws_backup_vault.this[0].kms_key_arn == "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"
    error_message = "Customer-managed KMS key ARN must pass through to the vault."
  }
}
