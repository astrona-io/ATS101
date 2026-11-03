# System Settings That Control Tenancy

Two settings decide how much freedom a normal user has before an administrator is involved: who may create projects and who may create an account. This part reads both settings, changes them and proves the effect with a real request.

## Reading the configuration

The system configuration is one JSON object. Each key has a `value` and an `editable` flag. Read the two settings:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq "{auth_mode, project_creation_restriction, self_registration}"'
```

`project_creation_restriction` is `everyone` or `adminonly`. `self_registration` is `true` or `false`, and it matters only in `db_auth` mode, because only there does Harbor own accounts.

## Who may create projects

On a new Harbor the value is `everyone`: any signed-in user may create a project and becomes its Project Admin. That is convenient and hard to govern, because every user can pick any name and any visibility. Prove it as `bob`:

```sh
ws curl -s -o /dev/null -w '%{http_code}\n' -u bob:BobPass1 -X POST -H 'Content-Type: application/json' -d '{"project_name":"bob-first"}' https://harbor.localtest.me:8443/api/v2.0/projects
```

The answer is 201. Now restrict creation. Save this as `restrict-creation.json`:

```json
{ "project_creation_restriction": "adminonly" }
```

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < restrict-creation.json
ws curl -s -o /dev/null -w '%{http_code}\n' -u bob:BobPass1 -X POST -H 'Content-Type: application/json' -d '{"project_name":"bob-second"}' https://harbor.localtest.me:8443/api/v2.0/projects
```

Harbor core now answers 403 to `bob`. The projects that `bob` already created stay, and he stays their Project Admin. The setting restricts only new projects.

## Self-registration

With `self_registration` set to `true`, the portal shows a sign-up link, and anyone who can reach Harbor can create a local account. The account has no membership, so it sees only public projects. Even so, open registration lets strangers use your registry's storage through public projects and fills the user table. Keep it `false` unless you run a public service. Change it the same way:

```json
{ "self_registration": false }
```

## The editable flag

Some keys are read-only after a change of state. `auth_mode` is the main example. Read its `editable` field:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq .auth_mode'
```

The field is `true` only while no user other than `admin` exists. Because the playground has users, it is `false`. This is why the authentication choice has to be made before the first user is created.

## Other settings that belong to administrators

The same configuration holds the token expiration time (`token_expiration`, in minutes), the prefix for robot account names, the default quota and the read-only mode. Each is a system-level choice that changes the behaviour of every project, which is why Harbor restricts the endpoint to system administrators.

You now know how to limit project creation, why self-registration is risky and how to read what can still be changed. The last part covers the end of the life of an account.

## Common pitfalls

> [!WARNING]
> - **Leaving `project_creation_restriction` at `everyone` on a shared registry.** Anyone can create projects.
> - **Expecting the restriction to remove existing projects.** It affects new projects only.
> - **Enabling `self_registration` on an internal registry.** Anyone with network access can create an account.
> - **Planning a change of authentication mode after users exist.** `editable` is then `false`.
