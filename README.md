# ATS101 — Project Management, RBAC & Multi-Tenancy (Harbor)

Course material for the **Project Management, RBAC & Multi-Tenancy** domain of
the Astrona Harbor training path ([ATP020](https://github.com/astrona-io/ATP020)),
which is **20% of the path**. Written for **Harbor v2.15.4** and the **Harbor
CLI v0.0.27**.

> **Status: draft, not yet run.** Every page, playground and lab was written
> from the Harbor 2.15 documentation, the CLI pages and the REST API
> definition. None has been started on a cluster, and no lab has passed
> `astrona test` yet. See `CLAUDE.md` for the facts most likely to be wrong.

The course opens with an Introduction in `sections/intro/`. Everything else
lives under `sections/`. Each section has one module (landing page, parts,
summary, playground, graded lab) and a capstone.

---

## Sections

| Section | Title | Labs | Topic |
| --- | --- | --- | --- |
| [010](sections/section-010) | Projects And Membership | 1 + capstone | Projects and roles |
| [020](sections/section-020) | Quotas, Tag Retention And Immutability | 1 + capstone | Storage control |
| [030](sections/section-030) | Identity Integration With OIDC | 1 + capstone | OIDC with Keycloak |
| [040](sections/section-040) | Identity Integration With LDAP | 1 + capstone | LDAP and groups |

## Modules

| Module | Reader | Parts | Lab |
| --- | --- | --- | --- |
| 010-01 | [Isolate Teams With Projects And Roles](sections/section-010/module-01/course.md) | 3 | [lab-01](sections/section-010/module-01/labs/lab-01) |
| 020-01 | [Control Storage With Quotas, Retention And Immutability](sections/section-020/module-01/course.md) | 3 | [lab-01](sections/section-020/module-01/labs/lab-01) |
| 030-01 | [Sign In To Harbor With OpenID Connect](sections/section-030/module-01/course.md) | 3 | [lab-01](sections/section-030/module-01/labs/lab-01) |
| 040-01 | [Sign In To Harbor With LDAP And Use LDAP Groups](sections/section-040/module-01/course.md) | 2 | [lab-01](sections/section-040/module-01/labs/lab-01) |

## Capstones

| Capstone | Scenario | Faults |
| --- | --- | --- |
| [010](sections/section-010/capstone/labs/lab-01) | Repair Project Access For Three Teams | a public project, a Project Admin who should not be a member, a Developer who should be Guest, a Developer who must be Maintainer |
| [020](sections/section-020/capstone/labs/lab-01) | Stop Retention From Deleting Releases | a retention rule that keeps one artifact, a schedule, unprotected releases, a quota too small to push |
| [030](sections/section-030/capstone/labs/lab-01) | Repair A Broken OIDC Sign-In | the wrong realm, the wrong groups claim, the wrong admin group, a redirect URI without the port |
| [040](sections/section-040/capstone/labs/lab-01) | Repair An LDAP Integration | the wrong user base DN, group filter and membership attribute, and a mistyped group DN |

---

## The lab environment

Every playground and lab is a **kind** cluster with Harbor 2.15.4 installed by
Helm (chart `harbor-helm` 1.19.4), reachable as
`https://harbor.localtest.me:8443` inside the cluster and through
`kubectl -n harbor port-forward svc/harbor 8443:8443` on the machine. A
`workstation` pod carries the client tools (`harbor`, `oras`, `regctl`,
`cosign`, `curl`, `jq`) and trusts Harbor's CA. Section 030 adds Keycloak
26.8.1, section 040 adds OpenLDAP.

The environment plumbing (`config.yaml`, bootstrap, testing, solution and
validation scripts, manifests, `prerequisites.md` and the author READMEs) is
the same in all twelve environments; change a shared piece everywhere.

## Running a playground or a lab

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/<section>/<module>/playground
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/<section>/<module>/labs/lab-01
astrona submit -c sections/<section>/<module>/labs/lab-01
astrona destroy <name>
```

Each lab grades the **final state of Harbor** by signing in as the users in
the task and really pushing, pulling and deleting. Several checks reject the
plausible but wrong fix: a public project instead of a member, a bigger role
than needed, deleting releases by hand, removing the quota.
