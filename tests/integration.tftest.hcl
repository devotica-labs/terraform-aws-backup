# Integration tests — apply + assert + destroy. Requires real AWS credentials.
# A vault + plan + selection + role is cheap and fast to create/destroy. No vault
# lock is set so teardown is clean (a locked vault cannot be deleted early).

provider "aws" {
  region = "ap-south-1"
}

variables {
  namespace = "dvtca"
  stage     = "integ"
  name      = "backup"

  # Tag-based selection so no real resources are required.
  selection_tags = {
    backup = "dvtca-integ"
  }

  tags = {
    Environment = "integration-test"
    Ephemeral   = "true"
  }
}

run "apply_and_assert" {
  command = apply

  assert {
    condition     = aws_backup_vault.this[0].arn != ""
    error_message = "Vault must be created with an ARN."
  }
  assert {
    condition     = aws_backup_plan.this[0].arn != ""
    error_message = "Plan must be created with an ARN."
  }
  assert {
    condition     = length(aws_iam_role.this) == 1
    error_message = "Service role must be created against the real API."
  }
  assert {
    condition     = aws_backup_selection.this[0].iam_role_arn != ""
    error_message = "Selection must reference the backup service role."
  }
}
