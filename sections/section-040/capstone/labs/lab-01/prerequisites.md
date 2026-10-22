# Prerequisites

Before starting this lab you should be able to:

- Run commands in a pod with `kubectl exec`.
- Read JSON with `jq`.
- Explain what a Harbor project is and what a project member's role decides.

## What the environment gives you

The lab environment builds itself before the task begins:

- A single-node `kind` Kubernetes cluster, with `kubectl` already pointed at it.
- **Harbor 2.15.4** in the namespace `harbor`, at `https://harbor.localtest.me:8443`, with the lab-only administrator `admin` and the password `Harbor12345`. On your machine, `kubectl -n harbor port-forward svc/harbor 8443:8443` opens the web portal there.
- The **workstation** pod in the namespace `workstation`, with `harbor` (the Harbor CLI v0.0.27), `oras`, `regctl`, `cosign`, `curl` and `jq`, and Harbor's certificate authority trusted.
- **OpenLDAP** in the namespace `ldap`, at `ldap://openldap.ldap.svc.cluster.local:389`, base DN `dc=example,dc=org`, administrator `cn=admin,dc=example,dc=org` with the lab-only password `admin-password`. Users `dave`, `erin` and `frank` under `ou=people` (passwords `DavePass1`, `ErinPass1`, `FrankPass1`); groups `inventory-devs` (dave) and `harbor-admins` (frank) under `ou=groups`.

## Working rules

- Everything is graded on the **final state of Harbor**, so check your work at the end and leave it in place.
- Change one thing at a time and check again.
- Never turn TLS off, never use `--insecure`, and never change the `admin` password.
