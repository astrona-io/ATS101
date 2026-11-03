# Overview: Understand Quota Accounting In Depth (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor and the workstation, and creates one project. There is no task, no `astrona submit` and no pass or fail. Explore, then `astrona destroy` and start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. The system administrator is `admin` with the lab-only password `Harbor12345`.
- The **workstation** pod with the `harbor` CLI v0.0.27, `oras`, `curl` and `jq`, trusting Harbor's certificate.
- The private project `inventory` with a quota of 100 MiB and the artifact `inventory/app:v1`.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation and `wst` does the same with a terminal.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
```

## Practice tasks

- Read the default quota with `ws curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq .storage_per_project`.
- Change the default to 8 MiB, create a project with the REST API (leave `storage_limit` out), and read its quota with `wst harbor quota list`.
- Push the same 3 MiB file under two tags into one project and compare the usage with a push into two projects.
- Delete an artifact and read the usage again.
