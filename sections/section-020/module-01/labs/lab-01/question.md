# Question

Solve this question on: `terminal`

**Time:** about 25 minutes · **Topic:** Storage control

## Scenario

The project `inventory` receives a build tag for every merged change and a release tag now and then. It has no limits and no cleanup, and the storage team wants that fixed before the next audit. Right now the repository `inventory/app` holds `build-1` to `build-6` and `release-1.0`, pushed in that order.

Run every Harbor command in the workstation pod. The system administrator is `admin` with the password `Harbor12345`.

## Your task

In the project `inventory`:

1. Limit the project's storage to **20 MiB**.
2. Make every tag that starts with `release-` impossible to overwrite or delete.
3. Create a tag retention policy that keeps the **3 most recently pushed** artifacts among the tags that start with `build-`, in every repository of the project.

## Constraints

- Do not run the retention policy for real; the grader runs it. A dry run is fine.
- Do not give the retention policy a schedule.
- Do not delete any artifact by hand.

## Done when

- The project's storage quota is exactly 20 MiB, a 30 MiB push is refused and a small push still works.
- An attempt to push `release-1.0` again is refused.
- When the grader runs the retention policy once, `inventory/app` keeps exactly `build-4`, `build-5`, `build-6` and `release-1.0`.
