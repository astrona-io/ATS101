# Design Retention And Immutability Rules In Depth

A retention rule that looks right can delete the wrong artifacts, and a rule that looks too careful can keep everything. The difference is in the details: the template, the parameter, the selector patterns, how rules combine and when the policy runs. A mistake here deletes artifacts for good.

A **retention policy** is the set of rules of one project plus one schedule. A **rule** names the artifacts to keep. An **immutability rule** protects matching tags from being overwritten or deleted. Keep one sentence in mind for the whole module: **a retention policy keeps what its rules select and deletes the rest, so read a dry run before every real run.**

The module has four parts. **Retention Templates** goes through the five templates and their parameters. **Selectors And Combining Rules** shows how patterns choose repositories and tags and how rules combine. **Running Retention** covers schedules, dry runs, executions and logs. **Immutability Rules In Depth** covers the protection rules and how they interact with retention, pushes and replication. A graded lab follows the fourth part.

## Learning objectives

After this module you can:

- Name the five retention templates and their parameters.
- Write repository and tag selectors with `matches` and `excludes` and doublestar patterns.
- Predict which artifacts a set of OR-combined rules keeps.
- Start a dry run and a real run, and read the executions and task logs.
- Set and remove a retention schedule.
- Create immutability rules and say what they stop.
- Explain how immutability and retention work together.

## Before you start

You need to know what a project, a repository, a tag and a digest are, and how a quota works. Harbor is already running.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. The `workstation` pod holds `harbor` (v0.0.27), `oras`, `curl` and `jq`. Harbor holds:

| Object | What it is |
| --- | --- |
| `admin` | The system administrator, with the lab-only password `Harbor12345` |
| `catalog` | A private project with `catalog/web` (`build-1` to `build-5` and `release-1.0`) and `catalog/api` (`build-1` to `build-4`) |

Every command in the parts runs in the workstation, and `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
