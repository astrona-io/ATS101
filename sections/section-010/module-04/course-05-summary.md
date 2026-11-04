# Summary

A robot account is an account for a program. It has a name, a secret, a list of permissions and an expiry. It works in every authentication mode, because Harbor checks its secret itself, and it cannot sign in to the portal. A pipeline that uses a robot no longer depends on a person's password or roles, and the audit log shows the pipeline as its own name.

Harbor builds the sign-in name from the prefix, the project and the name you chose: `robot$web+ci` for a project robot and `robot$deploy` for a system robot. The secret appears once, in the answer to the create call. A project robot belongs to one project. A system robot lists permissions for several projects, or for all of them with the namespace `*`, and only a system administrator creates it.

A robot has no roles. Its permissions are pairs of a resource and an action, such as `repository` with `push`, and anything not in the list is refused. A valid secret with a missing permission gets an authorization error, not an authentication error. The life of a robot is managed with `duration`, a secret refresh with `PATCH`, the `disable` field and deletion. The key facts to remember are these:

- Sign in with the full name, and quote the dollar sign.
- Give the shortest list of actions and the shortest duration that still work.
- Refreshing a secret stops the old one at once.
- Disable first, delete later.

<!-- astrona:playground:destroy -->
