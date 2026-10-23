# Overview: Isolate Teams With Projects And Roles (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor and the workstation, creates a few users and one project, and then waits. There is no task, no `astrona submit` and no pass or fail. Explore, change things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** in the namespace `harbor`, at `https://harbor.localtest.me:8443`. The system administrator is `admin` with the lab-only password `Harbor12345`.
- The **workstation** pod in the namespace `workstation`, with the `harbor` CLI v0.0.27, `oras`, `regctl`, `cosign`, `curl` and `jq`. It trusts Harbor's certificate.
- Three local users with no memberships: `alice` (`AlicePass1`), `bob` (`BobPass1`) and `carol` (`CarolPass1`).
- A private project `inventory` with one artifact, `inventory/notes:v1`.

To open the web portal, run `kubectl -n harbor port-forward svc/harbor 8443:8443` in a second terminal and open `https://harbor.localtest.me:8443`. Your browser warns about the lab certificate.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation. `push_as` pushes a small file as a user, and `pull_as` pulls an artifact as a user; both print whether it worked.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
push_as() {
  echo "$2" | ws sh -c 'oras login --registry-config /tmp/$0.json -u $0 --password-stdin harbor.localtest.me:8443 >/dev/null && cd /tmp && date > note.txt && oras push --registry-config /tmp/$0.json "$1" note.txt >/dev/null 2>&1 && echo "push allowed" || echo "push refused"' "$1" "$3"
}
pull_as() {
  echo "$2" | ws sh -c 'oras login --registry-config /tmp/$0.json -u $0 --password-stdin harbor.localtest.me:8443 >/dev/null && mkdir -p /tmp/pull && cd /tmp/pull && oras pull --registry-config /tmp/$0.json "$1" >/dev/null 2>&1 && echo "pull allowed" || echo "pull refused"' "$1" "$3"
}
echo Harbor12345 | ws harbor login https://harbor.localtest.me:8443 --username admin --password-stdin
```

Use them like this: `push_as alice AlicePass1 harbor.localtest.me:8443/inventory/notes:alice`, `pull_as carol CarolPass1 harbor.localtest.me:8443/inventory/notes:v1`.

## Practice tasks

- Add `alice` to `inventory` as Limited Guest, then as Guest, then as Developer. Run `push_as` and `pull_as` after each change and write down what changed.
- Create a public project with `ws harbor project create shared --storage-limit -1 --public`. Push to it as `admin` and pull from it as `bob`, who is not a member. Then try to push as `bob`.
- Make `carol` a Maintainer of `inventory` and delete an artifact as `carol` with `ws curl -s -o /dev/null -w '%{http_code}\n' -u carol:CarolPass1 -X DELETE https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories/notes/artifacts/v1`. Try the same as a Developer.
- List the members of `inventory` with the CLI and with the REST API, and match each role name to its number.
- Remove `alice` from `inventory` and check that her pull is refused at once.
