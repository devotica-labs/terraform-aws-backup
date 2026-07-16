plugin "aws" {
  enabled = true
  version = "0.30.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# tflint statically evaluates resource names with the label variable
# defaults (all null -> empty id) and wrongly flags an "invalid name".
# Real usage always supplies namespace/stage/name; the AWS API enforces
# the real constraint at apply. Disable these value checks.
rule "aws_backup_selection_invalid_name" { enabled = false }
rule "aws_backup_vault_invalid_name" { enabled = false }

rule "terraform_deprecated_interpolation" { enabled = true }
rule "terraform_documented_outputs"       { enabled = true }
rule "terraform_documented_variables"     { enabled = true }
rule "terraform_naming_convention"        { enabled = true }
rule "terraform_required_providers"       { enabled = true }
rule "terraform_required_version"         { enabled = true }
rule "terraform_typed_variables"          { enabled = true }
rule "terraform_unused_declarations"      { enabled = true }
