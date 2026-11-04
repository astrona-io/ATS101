# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** Robot accounts

## Scenario

The build pipeline of the `web` team pushes images to the project `web` and nothing else. An old robot account named `legacy` in `web` is still in use by nobody: it can push, pull and delete, and it never expires. The team needs a new robot account with only the rights the pipeline uses, and the old one must go.

Run every Harbor command in the workstation pod. The built-in system administrator is `admin` with the password `Harbor12345`. The user `alice` is Project Admin of `web` with the password `AlicePass1`.

## Your task

1. Create a project robot account named `ci` in the project `web`, with only the permissions `push` and `pull` on `repository`.
2. Give `ci` a lifetime of 30 days.
3. Delete the robot account `legacy` from the project `web`.

## Constraints

- Do not give `ci` rights in any other project.
- Do not give `ci` the `delete` action.
- Do not change the `admin` password.

## Done when

- A project robot `robot$web+ci` exists, is enabled, has exactly the permissions `repository` `push` and `repository` `pull` in `web`, and expires within 90 days.
- The robot `robot$web+legacy` no longer exists.
- Signed in with its secret, `ci` can push to `web` and cannot push to `api`.
