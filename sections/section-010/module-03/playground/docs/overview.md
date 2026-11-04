# Overview: Set Project Security Policies (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor with Trivy and the workstation, and creates one project with two members. There is no task, no `astrona submit` and no pass or fail. Explore, then `astrona destroy` and start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** at `https://harbor.localtest.me:8443`, with Trivy as the vulnerability scanner. The system administrator is `admin` with the lab-only password `Harbor12345`.
- The **workstation** pod with the `harbor` CLI v0.0.27, `oras`, `cosign`, `curl` and `jq`, trusting Harbor's certificate.
- The local users `alice` (`AlicePass1`) and `bob` (`BobPass1`).
- The private project `payments` with default metadata. `alice` is Project Admin and `bob` is Guest.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation and `wst` does the same with a terminal.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
wst() { kubectl -n workstation exec -it deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
```

## Practice tasks

- Read the metadata of `payments` with `GET /projects/payments` and `jq .metadata`.
- Turn on `auto_scan`, then push an image with `oras` and read the scan overview of the artifact.
- Set `prevent_vul` and a severity, change only the severity, and read the metadata again to see that the other keys stayed.
- Add `CVE-2024-3094` to the project allowlist, then replace the list with an empty one.
- Turn on `enable_content_trust_cosign` and see which pulls stop working.
