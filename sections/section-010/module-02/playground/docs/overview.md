# Overview: Manage Local Users And System Administrators (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor and the workstation, and creates three local users. There is no task, no `astrona submit` and no pass or fail. Explore, then `astrona destroy` and start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. The system administrator is `admin` with the lab-only password `Harbor12345`.
- The **workstation** pod with the `harbor` CLI v0.0.27, `oras`, `curl` and `jq`, trusting Harbor's certificate.
- The local users `alice` (`AlicePass1`), `bob` (`BobPass1`) and `temp-user` (`TempPass1`). Project creation is open to everyone.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation and `wst` does the same with a terminal.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
```

## Practice tasks

- List the users with `wst harbor user list` and read the same data with `GET /users` and `jq`.
- Create a project as `bob` with `curl -u bob:BobPass1`. Then set `project_creation_restriction` to `adminonly` and try again.
- Make `bob` a system administrator, check the `sysadmin_flag`, and remove the flag again.
- Delete `temp-user`, then search for the name and read what Harbor did to the record.
