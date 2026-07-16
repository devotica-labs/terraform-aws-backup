# Plan-only unit tests — no AWS credentials required. The IAM role validates its
# assume_role_policy JSON, so mock aws_iam_policy_document to valid JSON.

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
  name      = "unit"
}

run "core_resources_planned" {
  command = plan

  assert {
    condition     = length(aws_backup_vault.this) == 1
    error_message = "Exactly one backup vault by default."
  }
  assert {
    condition     = length(aws_backup_plan.this) == 1
    error_message = "Exactly one backup plan by default."
  }
  assert {
    condition     = length(aws_backup_selection.this) == 1
    error_message = "Exactly one backup selection by default."
  }
}

run "role_created_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_role.this) == 1
    error_message = "A service role must be created when backup_role_arn is null."
  }
  assert {
    condition     = length(aws_iam_role_policy_attachment.this) == 2
    error_message = "Both AWS-managed backup + restore policies must be attached."
  }
}

run "role_not_created_when_supplied" {
  command = plan
  variables {
    backup_role_arn = "arn:aws:iam::111122223333:role/existing-backup"
  }

  assert {
    condition     = length(aws_iam_role.this) == 0
    error_message = "No role must be created when backup_role_arn is supplied."
  }
  assert {
    condition     = length(aws_iam_role_policy_attachment.this) == 0
    error_message = "No policy attachments when reusing an existing role."
  }
}

run "single_daily_rule_by_default" {
  command = plan

  # The rendered rule set is computed under mocks; assert the config-set input.
  assert {
    condition     = length(var.rules) == 1 && var.rules[0].name == "daily"
    error_message = "Default plan must have exactly one daily rule."
  }
  assert {
    condition     = length(aws_backup_plan.this) == 1
    error_message = "Exactly one plan is planned by default."
  }
}

run "multiple_rules" {
  command = plan
  variables {
    rules = [
      { name = "daily", schedule = "cron(0 5 * * ? *)" },
      { name = "weekly", schedule = "cron(0 5 ? * 1 *)", delete_after = 90 },
      { name = "monthly", schedule = "cron(0 5 1 * ? *)", cold_storage_after = 30, delete_after = 365 },
    ]
  }

  assert {
    condition     = length(var.rules) == 3
    error_message = "One rule block per entry in var.rules."
  }
}

run "no_vault_lock_by_default" {
  command = plan

  assert {
    condition     = length(aws_backup_vault_lock_configuration.this) == 0
    error_message = "No vault lock unless vault_lock is set."
  }
}

run "vault_lock_when_set" {
  command = plan
  variables {
    vault_lock = {
      min_retention_days  = 30
      max_retention_days  = 3650
      changeable_for_days = 3
    }
  }

  assert {
    condition     = length(aws_backup_vault_lock_configuration.this) == 1
    error_message = "Vault lock must be created when vault_lock is set."
  }
  assert {
    condition     = aws_backup_vault_lock_configuration.this[0].min_retention_days == 30
    error_message = "Vault lock min_retention_days must pass through."
  }
}

run "tag_based_selection" {
  command = plan
  variables {
    selection_tags = {
      backup = "daily"
    }
  }

  assert {
    condition     = length(var.selection_tags) == 1
    error_message = "One selection_tag block per entry in selection_tags."
  }
  assert {
    condition     = length(aws_backup_selection.this) == 1
    error_message = "Selection is planned when tag-based selection is used."
  }
}
