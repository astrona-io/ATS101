# Overview: Design Retention And Immutability Rules In Depth (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor and the workstation, and fills a project with small artifacts. There is no task, no `astrona submit` and no pass or fail. Explore, then `astrona destroy` and start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. The system administrator is `admin` with the lab-only password `Harbor12345`.
- The **workstation** pod with the `harbor` CLI v0.0.27, `oras`, `curl` and `jq`, trusting Harbor's certificate.
- The private project `catalog` with `catalog/web` (`build-1` to `build-5`, then `release-1.0`) and `catalog/api` (`build-1` to `build-4`).

## Helpers

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
show_tags() {
  ws sh -c "curl -s -u admin:Harbor12345 'https://harbor.localtest.me:8443/api/v2.0/projects/catalog/repositories/$1/artifacts?with_tag=true' | jq -r '.[].tags[]?.name' | sort"
}
```

## Practice tasks

- Write a policy with the template `latestPushedK` and `latestPulledK`, and compare the dry run results.
- Use `nDaysSinceLastPush` with a value of 1 and predict what a dry run keeps.
- Exclude `release-*` with the `excludes` decoration instead of using immutability, and compare.
- Give the policy a cron schedule, read it back, then remove the schedule.
- Read the tasks and the log of an execution.
