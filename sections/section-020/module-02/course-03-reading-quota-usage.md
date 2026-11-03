# Reading Quota Usage

A quota is only useful if you can read how much of it is used. Harbor shows usage in the web portal, in the `harbor` CLI and in the REST API. This part reads the same numbers three ways, so that you can script a check and know which fields to trust.

## The harbor CLI

The `harbor quota list` command shows one row per project with the used storage and the hard limit. It draws a table only on a terminal, so run it through `kubectl exec -it`:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
kubectl -n workstation exec -it deploy/workstation -- harbor quota list
```

The `library` project, which every new Harbor creates, and `inventory` both appear. A limit of unlimited is shown for projects with no quota.

## The REST API

The `/quotas` endpoint returns the same data as JSON, and is the right choice for scripts. A quota belongs to a reference: the kind of object, here `project`, and its numeric ID. Read the ID of `inventory` and then its quota:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory | jq .project_id'
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/quotas?reference=project&reference_id=<PROJECT_ID>" | jq ".[0] | {id, hard, used}"'
```

Replace `<PROJECT_ID>` with the number from the first command. The object has an `id`, which is the ID of the quota and not of the project, a `hard` object with the limit, and a `used` object with the current usage. Both hold a `storage` field in bytes. A limit of `-1` means unlimited.

## Changing a quota

Change a quota with the `id` of the quota, not the project ID. The `harbor` CLI does the lookup for you:

```sh
ws harbor quota update --project-name inventory --storage 50MiB
```

With the REST API, send `{"hard":{"storage":52428800}}` in a `PUT` request to `/quotas/<QUOTA_ID>`. Only a system administrator can do this. A Project Admin can see the quota of the project in the web portal but cannot change it, which is by design: the person who consumes the storage should not set their own limit.

## The project summary

A project's own page of facts is `/projects/<name>/summary`. It includes a `quota` object with `hard` and `used` for that project, and counts of members and repositories. Read it:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory/summary | jq .quota'
```

This endpoint is useful for a dashboard of one project, because a Project Admin may read it. The `/quotas` list is useful for a report over every project, and only a system administrator may read it.

## Turning bytes into something readable

The API returns bytes, and a 20 MiB limit is `20971520`. The `jq` tool can do the arithmetic. This command prints the usage of every project in MiB:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/quotas?page_size=100" | jq -r ".[] | [.ref.name, (.used.storage/1048576|floor), .hard.storage] | @tsv"'
```

Each line shows the project name, the usage in whole MiB and the hard limit in bytes. Use this pattern in a report, and keep the `hard` value in bytes so that `-1` stays visible.

You can now read a quota three ways and change it with the right tool. The remaining question is what usage does when artifacts disappear.

## Common pitfalls

> [!WARNING]
> - **Using the project ID as the quota ID.** `PUT /quotas/<id>` takes the ID of the quota object.
> - **Reading `hard` as a size when it is `-1`.** That value means unlimited.
> - **Running `harbor quota list` without a terminal.** The CLI prints no table then; use `kubectl exec -it`.
> - **Giving a team's Project Admin the job of setting the limit.** The API refuses it.
