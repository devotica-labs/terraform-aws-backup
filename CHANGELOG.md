# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## [Unreleased]

### Added

- Initial release: an AWS Backup vault, plan, and selection with a service role
  and fintech-safe defaults — a KMS-encrypted vault (`kms_key_arn` optional), a
  single daily rule with 35-day retention, optional per-rule cold storage, and
  an optional compliance vault lock (WORM). The backup role is created by
  default (trusting `backup.amazonaws.com`, with the AWS-managed backup +
  restore policies) or reused via `backup_role_arn`. Selection is by explicit
  resource ARNs and/or tags. Native `label.tf` naming; derived from
  `cloudposse/terraform-aws-backup`.
