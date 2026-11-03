# Question

Solve this question on: `terminal`

**Time:** about 25 minutes · **Topic:** Storage control

## Scenario

The project `catalog` holds two repositories. `web` has `build-1` to `build-5` and `release-1.0`. `api` has `build-1` to `build-4`. The web team wants only its two newest builds. The api team wants to keep every tag of `api`, because it replays old builds in tests. Releases must never change or disappear.

Run every Harbor command in the workstation pod. The system administrator is `admin` with the password `Harbor12345`.

## Your task

In the project `catalog`:

1. Make every tag that starts with `release-` impossible to overwrite or delete.
2. Create one tag retention policy with two rules:
   - keep the **2 most recently pushed** artifacts among tags that start with `build-`, in every repository;
   - keep **every** artifact in the repository `api`.

## Constraints

- Do not run the retention policy for real; the grader runs it. A dry run is fine.
- Do not give the retention policy a schedule.
- Do not delete any artifact by hand.

## Done when

- The policy has two enabled rules and no schedule, and `release-*` is immutable.
- An attempt to push `release-1.0` again is refused.
- When the grader runs the policy once, `catalog/web` keeps `build-4`, `build-5` and `release-1.0`, and `catalog/api` keeps `build-1` to `build-4`.
