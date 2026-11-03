# Summary

A retention policy is a list of rules and one schedule. Each rule keeps artifacts: a template decides how many, and selectors decide among which. The templates keep the K most recently pushed, the K most recently pulled, the artifacts pushed or pulled within N days, or everything. The count applies to each repository, and an artifact that was never pulled has no pull time.

Selectors work on repositories and on tags, with the decorations `repoMatches`, `repoExcludes`, `matches` and `excludes` and doublestar patterns. Repository names are written without the project. Rules combine with OR, a project may have up to 15, and an artifact survives if any rule keeps it. A rule that keeps nothing of a tag lets a real run delete it.

A policy runs by hand or on a six-field cron schedule. A dry run shows, per repository, how many artifacts exist and how many are kept, and deletes nothing. A real run cannot be undone, so the dry run and its task log come first.

An immutability rule makes matching tags impossible to overwrite, re-tag or delete for every user. Retention never deletes an immutable artifact, and replication cannot overwrite one. Use retention for builds, immutability for releases, and narrow patterns, because a pattern such as `**` blocks even `latest`.

- Rules say what to keep, and OR joins them.
- Read a dry run before a real run.
- Repository patterns omit the project name.
- Immutability protects the tag, retention manages the rest.

<!-- astrona:playground:destroy -->
