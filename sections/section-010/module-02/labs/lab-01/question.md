# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Users and administration

## Scenario

The platform team hands the daily administration of Harbor to `alice`. At the same time, the security team wants only administrators to create projects, so that project names and quotas stay under control. A contractor account, `temp-user`, is no longer needed.

Run every Harbor command in the workstation pod. The built-in system administrator is `admin` with the password `Harbor12345`. The users `alice` and `bob` have the passwords `AlicePass1` and `BobPass1`.

## Your task

1. Make `alice` a system administrator. `bob` must stay a normal user.
2. Allow only system administrators to create projects.
3. Delete the user `temp-user`.

## Constraints

- Do not change the `admin` password.
- Do not delete `alice` or `bob`.
- Do not make `bob` a system administrator.

## Done when

- `alice` has the system administrator flag and `bob` does not.
- The setting `project_creation_restriction` is `adminonly`, `bob` receives HTTP 403 when he creates a project and `alice` can create one.
- `temp-user` no longer exists.
