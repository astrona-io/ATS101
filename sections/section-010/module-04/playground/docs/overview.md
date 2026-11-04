# Overview: Automate Access With Robot Accounts (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor and the workstation, and creates one user and two projects. There is no task, no `astrona submit` and no pass or fail. Explore, then `astrona destroy` and start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. The system administrator is `admin` with the lab-only password `Harbor12345`.
- The **workstation** pod with the `harbor` CLI v0.0.27, `oras`, `curl` and `jq`, trusting Harbor's certificate.
- The local user `alice` (`AlicePass1`), Project Admin of `web`.
- The private projects `web` and `api`, with no artifacts and no robot accounts.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation and `wst` does the same with a terminal.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
```

## Practice tasks

- Create a project robot `ci` in `web` that can push and pull, and keep the secret from the answer.
- Sign `oras` in with the robot, push to `web`, and see what happens when you push to `api`.
- Create a system robot that can only pull from both projects.
- Refresh a secret with `PATCH`, and check that the old secret stops working.
- Disable a robot, try to sign in, then delete it.
