# Sign In To Harbor With OpenID Connect — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-101-playground-030-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading

> **Not yet run.** This playground was written from the Harbor 2.15
> documentation and has not been started on a cluster yet.

A single sandbox environment that spins up, runs OS prep, and stays running so
you can explore the module's topic on a clean machine. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-101-playground-030-01
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-101-playground-030-01`), not
the config path. `astrona submit` and `astrona test` do not apply — there is no
grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime + bootstrap only) |
| `bootstrap/prepare.sh` | Helm, CoreDNS rewrites, Harbor, extra services, workstation, starting state |
| `manifests/harbor-values.yaml` | Helm values for Harbor |
| `manifests/lab-start.yaml` | The workstation pod |
| `manifests/keycloak.yaml` | Extra services for this module |
| `docs/overview.md` | What the environment contains and ideas to try |
