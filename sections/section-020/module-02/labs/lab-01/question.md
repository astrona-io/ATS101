# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Storage control

## Scenario

The storage team wants every new project to start with a small quota, so that no team can fill the disk by accident. Today new projects have no limit. The existing project `inventory` has a quota of 100 MiB, which is too large.

Run every Harbor command in the workstation pod. The system administrator is `admin` with the password `Harbor12345`.

## Your task

1. Set the default storage quota for new projects to **15 MiB**.
2. Create a private project named `reports`. It must receive the 15 MiB quota from the default, without you setting a quota on the project itself.
3. Change the quota of the existing project `inventory` to **40 MiB**.

## Constraints

- Create `reports` after you change the default.
- Do not delete `inventory` or its artifact.
- Do not change the `admin` password.

## Done when

- The default storage quota is exactly 15 MiB.
- `reports` exists, is private, has a 15 MiB quota, refuses a 20 MiB push and accepts a small push.
- `inventory` has a quota of exactly 40 MiB.
