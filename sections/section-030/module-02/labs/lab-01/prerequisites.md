# Prerequisites

Before starting this lab you should be able to:

- Run commands in a pod with `kubectl exec`.
- Read JSON with `jq`.
- Explain how Harbor signs users in through an OpenID Connect provider.
- Explain what a group member of a project is and what the five project roles allow.

## What the environment gives you

The lab environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Harbor 2.15.4** in the namespace `harbor`, at `https://harbor.localtest.me:8443`, with the lab-only administrator `admin` and the password `Harbor12345`. On your machine, `kubectl -n harbor port-forward svc/harbor 8443:8443` opens the web portal there.
- The **workstation** pod in the namespace `workstation`, with `harbor` (the Harbor CLI v0.0.27), `oras`, `regctl`, `cosign`, `curl` and `jq`, and Harbor's certificate authority trusted.
- **Keycloak 26.8.1** in the namespace `keycloak`, at `http://keycloak.localtest.me:8180` (inside the cluster, and on your machine while `kubectl -n keycloak port-forward svc/keycloak 8180:8180` runs). Realm `harbor` with the confidential client `harbor` (secret `harbor-client-secret`), the groups `report-writers`, `report-readers` and `platform-admins`, and the users `alice`, `carol` and `bob` (lab-only passwords `AlicePass1`, `CarolPass1`, `BobPass1`). Keycloak administrator: `admin` / `admin`.
- Harbor is **already in OIDC mode** with this realm. The project `reports` holds one artifact, `reports/app:seed`.

## Working rules

- Everything is graded on the **final state of Harbor**, so check your work at the end and leave it in place.
- Change one thing at a time and check again.
- Never turn TLS off, never use `--insecure`, and never change the `admin` password.
