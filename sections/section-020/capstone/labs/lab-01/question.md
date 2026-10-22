# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** Storage control

## Scenario

Last week someone set up storage control for `inventory` in a hurry. Since then, the team cannot push its new images, and a reviewer noticed that the nightly cleanup job would delete far more than old builds. The repository `inventory/app` holds `build-1` to `build-6`, `release-1.0` and `release-1.1`. The policy has not run yet. Fix it before it does.

Run every Harbor command in the workstation pod. The system administrator is `admin` with the password `Harbor12345`.

## Your task

1. Find out what the current retention policy of `inventory` would delete, and why the team's pushes fail.
2. Make the policy keep the 3 most recently pushed `build-*` artifacts in every repository, and make sure no release (`release-*`) is ever deleted or overwritten.
3. Stop the policy from running on a schedule; the team will start it by hand.
4. Raise the storage quota so the team can push artifacts of about 10 MiB.

## Constraints

- Keep the existing retention policy and change it. Do not delete the policy and leave the project without one.
- Set the quota to exactly **50 MiB**. Do not remove the limit.
- Do not delete any artifact by hand, and do not run the policy for real; the grader runs it.

## Done when

- The quota is 50 MiB and a 10 MiB push works.
- Pushing `release-1.0` again is refused.
- The retention policy has no schedule.
- When the grader runs the policy once, `inventory/app` keeps exactly `build-4`, `build-5`, `build-6`, `release-1.0` and `release-1.1`.
