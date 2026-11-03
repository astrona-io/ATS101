# System Administrators And Project Roles

Harbor has two kinds of rights. A project role applies to one project. The administrator flag applies to everything. Teams often give the flag to people who only need a project role, which weakens every isolation rule in Harbor. This part shows the difference by running the same actions with both.

## What the flag allows

A **system administrator** can do what no project role can: create and delete users, set the system configuration, set quotas, create global labels, read the audit log of the system and see every project, public or private, without being a member. The built-in `admin` account has the flag, and any other user can receive it.

A **Project Admin** is the top role inside one project. This user manages members, retention and immutability rules in that project, and cannot do anything outside of it. Even in its own project, a Project Admin cannot change the quota.

## Granting the flag

The flag changes with its own request. Find the ID of `bob`, then save this as `sysadmin-true.json`:

<!-- astrona:playground:renew -->

```json
{ "sysadmin_flag": true }
```

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/users/search?username=bob" | jq ".[] | {user_id, username}"'
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/users/<USER_ID>/sysadmin < sysadmin-true.json
```

Replace `<USER_ID>` with the number from the first command. Harbor answers 200. Now check that `bob` can list users, which a normal user cannot:

```sh
ws curl -s -o /dev/null -w '%{http_code}\n' -u bob:BobPass1 https://harbor.localtest.me:8443/api/v2.0/users
```

The status code is 200. This course uses the REST API for the flag, because the request is the same everywhere.

## Removing the flag

Send `{ "sysadmin_flag": false }` to the same endpoint, and the same request as `bob` returns 403 again. Remove the flag the day a person changes role. A flag that nobody reviews stays for years.

## Comparing the two with one action

The difference is visible when `alice`, who is Project Admin of a project but not a system administrator, tries to set the project quota. Harbor refuses with 403. The same request as `admin` works. Only the flag can set quotas, create users or change the configuration.

The reverse also holds. A system administrator who is not a member of a private project can still see it. This is why the flag should be rare: it bypasses project membership, and every pull or delete by such a user is not limited by roles.

## Passwords

Users change their own password with `PUT /users/<id>/password`, which needs the old password and the new one. A system administrator can set a new password for another local user without the old one. Both actions apply only to `db_auth`. With LDAP or OIDC, Harbor does not hold the password, and the identity provider decides.

You now know the global right, how to grant it and what it allows. The next part looks at the two system settings that shape who may create projects and who may register.

## Common pitfalls

> [!WARNING]
> - **Giving the flag to a team lead who needs a Project Admin role.** The flag bypasses membership everywhere.
> - **Expecting a Project Admin to set a quota.** Only a system administrator can.
> - **Never reviewing the flag.** Remove it when a person changes role.
> - **Trying to change an LDAP or OIDC user's password in Harbor.** The identity provider owns it.
