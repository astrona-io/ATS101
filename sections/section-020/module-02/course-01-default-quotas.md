# Default Quotas And Project Quotas

An administrator who creates fifty projects does not want to set fifty quotas by hand. Harbor solves this with a default quota in the system configuration. This part shows where that default is stored, which projects it affects, and how it relates to the quota of a single project.

## Two places for a limit

A project has its own quota, and the system has a default quota. The project's quota is the limit Harbor enforces. The default is only a starting value: when Harbor creates a project, it copies the default into the new project's quota. After that, the two are independent.

The default is stored in the system configuration as `storage_per_project`, in bytes. The value `-1` means no limit, and it is the value on a new Harbor. Read it:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq .storage_per_project'
```

The command prints an object with a `value` field and an `editable` field. The `value` is `-1` until an administrator changes it.

## Changing the default

Only a system administrator can change the system configuration. The REST API accepts the new value in bytes. 10 MiB is 10485760 bytes. Save this as `default-quota.json`:

```json
{ "storage_per_project": 10485760 }
```

Send it with a `PUT` request and read the value back:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < default-quota.json
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq .storage_per_project.value'
```

The web portal shows the same setting under Configuration, then Project Quotas, where it accepts the units MiB, GiB and TiB. The value `-1` sets the default back to unlimited.

## What the default does not do

The default applies only to projects that Harbor creates after the change. The existing project `inventory` keeps its quota of 100 MiB. To prove it, read the quota of `inventory`:

```sh
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
kubectl -n workstation exec -it deploy/workstation -- harbor quota list
```

The `harbor` CLI draws the table only on a terminal, so the second command uses `-it`. The row for `inventory` still shows 100 MiB, not 10 MiB.

Now create a project. The `harbor project create` command needs `--storage-limit`, and any value you pass sets the quota on the project itself, so the default would not apply. Use the REST API and leave `storage_limit` out. Save this as `project-sandbox.json`:

```json
{ "project_name": "sandbox", "metadata": { "public": "false" } }
```

Create the project and list the quotas again:

```sh
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects < project-sandbox.json
kubectl -n workstation exec -it deploy/workstation -- harbor quota list
```

The row for `sandbox` shows 10 MiB. The project got its quota from the default at the moment Harbor created it.

## Which limit wins

When a push arrives, Harbor checks the quota of the project that receives the artifact. It never reads the default at that time. If you change the default to 50 MiB later, `sandbox` still has 10 MiB. If you change the quota of `sandbox` to 20 MiB, the default stays at 50 MiB. This also explains the order of work for an administrator: set the default first, then create the projects.

You now know where a limit is stored, how the default reaches a new project, and why the default never changes a project that already exists. The next question is what Harbor adds up when it compares usage with the limit.

## Common pitfalls

> [!WARNING]
> - **Expecting the default to change existing projects.** It does not. Set each existing project's quota yourself.
> - **Creating a project with `harbor project create --storage-limit -1` and expecting the default.** The flag sets the quota to unlimited on that project.
> - **Setting a value in MiB in the REST API.** The `storage_per_project` field takes bytes.
> - **Expecting a Project Admin to change a quota.** Only a system administrator can.
