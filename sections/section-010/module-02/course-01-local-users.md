# Local Users And Database Authentication

A project needs members, and members need accounts. Harbor can take accounts from an identity provider, but its default is its own database. This part creates local users, reads them back and explains which fields matter.

## Authentication modes in one paragraph

Harbor has an **authentication mode**: `db_auth` (local users in the Harbor database), `ldap_auth` or `oidc_auth`. A new Harbor uses `db_auth`. In this mode an administrator creates users, and users may register themselves if the setting allows it. The mode can be changed only while no user other than `admin` exists, so the choice is made early.

## Creating users

The `harbor` CLI creates a user with four required values. Sign in as `admin` and create `carol`:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
ws harbor user create --username carol --password CarolPass1 --email carol@example.com --realname Carol
```

The password needs at least eight characters with an upper-case letter, a lower-case letter and a number. `--password` places the password on the command line, which is acceptable in a lab and not on a real system. The same user through the REST API needs a JSON body. Save this as `user-dan.json`:

```json
{
  "username": "dan",
  "email": "dan@example.com",
  "realname": "Dan",
  "password": "DanPass1",
  "comment": "created in the playground"
}
```

Send it:

```sh
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/users < user-dan.json
```

Harbor answers with HTTP 201 and an empty body. If the username or the email already belongs to another user, Harbor answers 409.

## Reading users

List users with the CLI on a terminal, or with the API:

```sh
kubectl -n workstation exec -it deploy/workstation -- harbor user list
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/users?page_size=100" | jq -r ".[] | [.user_id, .username, .email, .sysadmin_flag] | @tsv"'
```

Each user has a numeric `user_id`. Most user endpoints take this number, not the name. To find it, search by name:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/users/search?username=carol" | jq ".[] | {user_id, username}"'
```

The search matches names that contain the text, so check the `username` before you use the ID.

## The fields that matter

- `username`: unique, and the name the user types at sign-in and in `docker login`.
- `email`: unique among users.
- `realname`: free text, shown in the portal.
- `comment`: free text for notes, for example why the account exists.
- `sysadmin_flag`: whether the user is a system administrator. It is `false` for a new user.

Only a system administrator can list all users. When `bob` asks for `GET /users`, Harbor answers 403, because user data is private.

## What a new user can do

A new user has no project memberships. The user can sign in, see public projects and, depending on a system setting, create projects. The user can not see any private project until an administrator or a Project Admin adds the user as a member. A user is therefore safe to create early, and access is a separate decision.

You now know how to create and find local users. The next question is which of them should hold the global administrator right, and how that differs from a project role.

## Common pitfalls

> [!WARNING]
> - **Using the name where the API needs the numeric ID.** Search first, then use `user_id`.
> - **Putting a real password on the command line.** It stays in shell history and in the process list.
> - **Reusing an email address.** Harbor answers 409 for a second user with the same email.
> - **Planning to change the authentication mode later.** It is locked once local users exist.
