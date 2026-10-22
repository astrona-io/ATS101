# Control Storage With Quotas, Retention And Immutability

The project `inventory` receives a new build every time someone merges a change: `build-1`, `build-2`, and so on, plus a `release-1.0` now and then. Nobody ever deletes anything. In a few months the project holds thousands of tags, most of them useless, and the registry's storage is full. Deleting old builds by hand is slow and risky, because one wrong click deletes a release that is still running in production.

Harbor has three tools for this. A **storage quota** is the most bytes a project may store. A **tag retention rule** says which artifacts to keep; a retention run deletes everything else. A **tag immutability rule** makes matching tags impossible to overwrite or delete. Keep one sentence in mind: **retention removes what you no longer need, immutability protects what you must keep, and the quota stops whatever the rules miss.**

The module has three parts. **Storage Quotas** sets a quota and shows a push that does not fit. **Tag Retention Rules** writes a rule that keeps the newest builds, checks it with a dry run and runs it. **Tag Immutability Rules** protects the releases and shows how immutability and retention work together. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Explain how Harbor counts storage in a project.
- Set a project's storage quota as system administrator, and recognise a push refused by the quota.
- Choose a retention rule template, and match or exclude tags with patterns.
- Explain how several retention rules combine.
- Run a retention policy as a dry run, read the result, and then run it for real.
- Write a tag immutability rule and say what it stops.
- Combine retention and immutability so releases survive every retention run.

## Before you start

You need to know what a Harbor project, a repository, a tag and a digest are, and how to run commands in a pod with `kubectl exec`. Retention runs delete artifacts and cannot be undone, so every page runs a dry run first.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. The `workstation` pod holds the `harbor` CLI, `oras`, `curl` and `jq`, and trusts Harbor's certificate. The system administrator is `admin` with the lab-only password `Harbor12345`. Harbor holds:

| Object | What it is |
| --- | --- |
| `inventory` | A private project with no quota limit |
| `inventory/app` | A repository with seven small artifacts: `build-1` to `build-6`, then `release-1.0`, pushed two seconds apart |

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
