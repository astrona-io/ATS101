# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Projects and roles

## Scenario

Two teams start using Harbor this week. `alice` builds images for team A, `bob` builds images for team B, and `carol` audits both teams. Each team must keep its images to itself, and the auditor must be able to read everything and change nothing. The three users already exist; nothing else has been set up.

Run every Harbor command in the workstation pod, for example `kubectl -n workstation exec -it deploy/workstation -- harbor project list`. The system administrator is `admin` with the password `Harbor12345`.

## Your task

1. Create two projects, `team-a` and `team-b`. Neither may be readable without signing in.
2. Make `alice` able to push and pull in `team-a`, and `bob` able to push and pull in `team-b`.
3. Make `carol` able to pull from both projects.

## Constraints

- Give each user the **smallest role** that lets them do the work in the task. A bigger role is graded as wrong.
- `alice` must have no access to `team-b`, and `bob` no access to `team-a`.
- `carol` must not be able to push to either project.
- Do not change the password of any user, and do not make any user a system administrator.

## Done when

- `team-a` and `team-b` are private, and an anonymous pull is refused.
- `alice` is Developer of `team-a` only, `bob` is Developer of `team-b` only, and `carol` is Guest of both.
- A push as each team member works in their own project and is refused in the other one, and a pull across teams is refused.
- `carol` can pull from both projects and cannot push to either.
