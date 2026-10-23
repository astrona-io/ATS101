# Overview: Control Storage With Quotas, Retention And Immutability (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor and the workstation, fills one project with small artifacts, and then waits. There is no task, no `astrona submit` and no pass or fail. Explore, delete things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. The system administrator is `admin` with the lab-only password `Harbor12345`.
- The **workstation** pod with the `harbor` CLI v0.0.27, `oras`, `curl` and `jq`, trusting Harbor's certificate.
- The private project `inventory`, with no quota limit, and the repository `inventory/app` with seven small artifacts: `build-1` to `build-6` and then `release-1.0`, pushed two seconds apart.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation. `harbor_api` calls the REST API as `admin` and takes the method, the path after `/api/v2.0` and, optionally, a JSON file on your machine. `show_tags` lists the tags of `inventory/app`.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
harbor_api() {
  if [ -n "${3:-}" ]; then
    ws curl -s -u admin:Harbor12345 -X "$1" -H 'Content-Type: application/json' --data-binary @- "https://harbor.localtest.me:8443/api/v2.0$2" < "$3"
  else
    ws curl -s -u admin:Harbor12345 -X "$1" "https://harbor.localtest.me:8443/api/v2.0$2"
  fi
}
show_tags() {
  harbor_api GET "/projects/inventory/repositories/app/artifacts?with_tag=true" | jq -r '.[].tags[]?.name' | sort
}
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
```

Use them like this: `harbor_api GET /projects/inventory | jq .metadata`, `show_tags`.

## Practice tasks

- Set a quota of 10 MiB with `ws harbor quota update --project-name inventory --storage 10MiB`, push files of 5 MiB until one is refused, and compare the usage in `ws harbor quota list` with what you pushed.
- Write a retention policy that keeps the 2 most recently pushed artifacts of every tag. Run it as a dry run and predict the task counts before you read them.
- Add a second rule with the template `always` (`"template": "always"`) for `release-*`, and run the dry run again. Compare the counts.
- Make `release-*` immutable, then try to push `release-1.0` again and to delete it through the API. Note the HTTP codes.
- Run the retention policy for real and check with `show_tags` which tags are left.
