# Running Retention

A policy does nothing until it runs. It can run on a schedule or by hand, and a run can be real or a dry run. This part starts both kinds of run, reads the result, and sets a schedule.

## Dry run and real run

A **dry run** works out what the policy would delete and deletes nothing. A **real run** deletes. Both are an **execution** of the policy, and each execution has tasks, one per repository. Start a dry run:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' -d '{"dry_run":true}' https://harbor.localtest.me:8443/api/v2.0/retentions/<RETENTION_ID>/executions
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/retentions/<RETENTION_ID>/executions?page_size=1" | jq ".[0] | {id, status, dry_run}"'
```

Replace `<RETENTION_ID>` with the `retention_id` of the project. The retention work runs in the job service, so the execution first has a status of `Running` and then `Succeed`. Read the status again until it changes.

## Reading the tasks

Each execution has one task per repository. Read them with the execution ID:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/retentions/<RETENTION_ID>/executions/<EXECUTION_ID>/tasks" | jq ".[] | {id, repository, status, total, retained}"'
```

The `total` field is the number of artifacts the task looked at, and `retained` is the number it keeps. The difference is the number a real run would delete. For `catalog/web` with the two-rule policy of the earlier part, expect `total` 6 and `retained` 3 once `release-1.0` is protected. Check the numbers against your prediction before you start a real run.

The log of one task lists every artifact with the decision Harbor made. Read it with `GET .../tasks/<TASK_ID>`. The log is the way to learn why one artifact was kept or removed.

## Starting a real run

A real run uses `{"dry_run":false}` and cannot be undone. Harbor deletes the artifacts, and the usage in the quota falls. Run the dry run first, read the tasks, and only then run for real.

## A schedule

The policy has one trigger. The kind `Schedule` with an empty `cron` means no schedule. A schedule is a cron expression in Harbor's format, which has six fields because the first is seconds. The expression `0 0 2 * * *` runs every day at 02:00. Set it by sending the whole policy with a new `cron`:

```json
{ "kind": "Schedule", "settings": { "cron": "0 0 2 * * *" } }
```

This object is the `trigger` of the policy body. All the rules of a project share the one schedule. A schedule runs real executions, so only add it after you trust the policy. The portal also offers hourly, daily and weekly presets that fill the cron field.

## When something goes wrong

If an execution ends as `Failed`, read its tasks and the log of the failing task. If an execution stays `Running`, the job service may be busy or down. Check the job service pod in the `harbor` namespace with `kubectl -n harbor get pods` before you start another run, because two runs at the same time make the result hard to read.

You now know how to run a policy safely, read what it decided and automate it. The last part adds the rule that protects tags from every change, not only from retention.

## Common pitfalls

> [!WARNING]
> - **Starting a real run to see what happens.** Use a dry run.
> - **Reading the status right after you start the run.** It is `Running` first.
> - **Setting a schedule on an untested policy.** It deletes every day.
> - **Using five-field cron.** Harbor's expression starts with seconds.
