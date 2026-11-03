# Summary

A local user is an account that Harbor stores in its database in `db_auth` mode. Creating one needs a username, an email address, a real name and a password. The username and the email must be unique, most user endpoints take the numeric `user_id`, and only a system administrator can list users. A new user has no memberships and sees only public projects.

The administrator flag is the only global right. A system administrator can create users, change the system configuration, set quotas and see every project without being a member. A Project Admin has the highest role inside one project and nothing outside it. Because the flag bypasses membership, it should be given to few people, to named accounts and not to a shared one, and it should be reviewed.

Two settings shape tenancy. `project_creation_restriction` set to `adminonly` makes Harbor refuse project creation by normal users with HTTP 403 and does not affect existing projects. `self_registration` lets strangers create accounts and is usually off. The authentication mode cannot be changed after users exist, which the `editable` field shows.

Offboarding has two steps: remove memberships and the flag, then delete the account. Harbor renames a deleted user, keeps the artifacts in their projects and keeps the audit history. Pipelines that used the personal credentials stop working, so they need a robot account first.

- The flag is global; a role is per project.
- `adminonly` restricts only new projects.
- Delete a user by `user_id`, never by name.
- Artifacts belong to projects, not to people.

<!-- astrona:playground:destroy -->
