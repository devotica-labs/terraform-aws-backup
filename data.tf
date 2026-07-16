# Trust policy for the dedicated backup service role — allows the AWS Backup
# service principal to assume it. Only rendered when the module creates the role.
data "aws_iam_policy_document" "assume_role" {
  count = local.create_role ? 1 : 0

  statement {
    sid     = "AllowBackupServiceAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}
