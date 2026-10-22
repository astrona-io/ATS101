---
estimated_duration: 20m
---

# Isolate Two Teams With Projects And Roles

- **ID:** LAB
- **Slug:** ats-101-lab-010-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona graded lab

Graded lab on Harbor 2.15.4. Read `question.md` for the task; `solution.md` is the walkthrough.

> **Not yet run.** This lab was written from the Harbor 2.15 documentation
> and has not passed `astrona test` yet.

## Run it

```sh
astrona run -c .
astrona submit
astrona destroy ats-101-lab-010-01
```

`astrona destroy` takes the environment name (`metadata.name` = `ats-101-lab-010-01`), not
the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition, bootstrap and grading |
| `question.md` | The task |
| `solution.md` | Step-by-step walkthrough |
| `prerequisites.md` | Assumed knowledge and what the environment provides |
| `bootstrap/` | Helm, Harbor, extra services and the workstation, then the starting state |
| `manifests/` | Helm values, the workstation pod and any extra services |
| `solution/` | Reference solution used by `astrona test` |
| `testing/` | Waits for Harbor |
| `validation/` | Grading scripts, one per check |
