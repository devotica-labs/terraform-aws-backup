# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## 0.1.0 (2026-07-16)


### Features

* **ci:** add architecture-diagram workflow + renderer ([223df6b](https://github.com/devotica-labs/terraform-aws-backup/commit/223df6b51f16261023ce0ce9e5cb225be98352e8))
* initial release of terraform-aws-backup ([f6feea2](https://github.com/devotica-labs/terraform-aws-backup/commit/f6feea2956b955e6618b7a40507bd7af43e89d44))


### Bug Fixes

* **ci:** drop dead pip/scripts dependabot entry; tflint clean ([80ca64e](https://github.com/devotica-labs/terraform-aws-backup/commit/80ca64eb77f48228421f95340f08b8e425ca7233))
* **ci:** pass CI on terraform 1.9.5 ([46bf259](https://github.com/devotica-labs/terraform-aws-backup/commit/46bf259297156b761dc846af6950f31de1cce4b4))

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
