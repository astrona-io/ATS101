# Question

Solve this question on: `terminal`

**Time:** about 30 minutes · **Topic:** Projects and roles

## Scenario

A colleague set up Harbor for two teams in a hurry and then went on holiday. The projects `team-a` and `team-b` exist, and four users have memberships. The security review found several problems, but the notes only say "access is wrong". The intended access is:

| User | Intended access |
| --- | --- |
| `alice` | Pushes and pulls in `team-a` |
| `bob` | Pushes and pulls in `team-b`; no access to `team-a` at all |
| `carol` | Reads `team-b` only; changes nothing |
| `dan` | Pushes, pulls and deletes old artifacts in `team-a` |

Nobody outside these memberships may read either project. Run every Harbor command in the workstation pod. The system administrator is `admin` with the password `Harbor12345`; the user passwords are `AlicePass1`, `BobPass1`, `CarolPass1` and `DanPass1`.

## Your task

1. Find every way the current set-up differs from the intended access. Read the projects and their members with the `harbor` CLI or the REST API.
2. Fix each difference so the intended access is exactly what Harbor allows.

## Constraints

- Do not delete or recreate `team-a` or `team-b`: they hold artifacts.
- Give each user the smallest role that gives the intended access. `alice` stays Developer.
- Do not change any user's password and do not make any user a system administrator.

## Done when

- `team-a` is private, and an anonymous pull from it is refused.
- `bob` cannot pull from `team-a` and can still push to `team-b`.
- `carol` can pull from `team-b` and cannot push to it.
- `dan` can delete an artifact in `team-a`, and `alice` cannot.
