# Automate Access With Robot Accounts

A build pipeline pushes images all day and nobody sits at the keyboard. If the pipeline signs in as a person, it uses that person's password, it gets that person's roles, and it stops working on the day that person leaves. Harbor has a separate kind of account for automation, so that a pipeline gets exactly the rights it needs and nothing more.

A **robot account** is a Harbor account for a program. It has its own name, its own secret, a list of permissions and an optional expiry time. It cannot sign in to the portal. Keep one sentence in mind for the whole module: **a robot account is a secret plus an explicit list of actions on a project, and it should have the shortest list and the shortest life that still lets the job run.**

The module has four parts. **Robot Accounts And Their Names** creates a project robot account and shows its name and secret. **Permissions: Resources, Actions And Scope** chooses what a robot may do and where. **Using A Robot Account In A Pipeline** signs a client in with the robot and proves the limits. **Operating Robot Accounts** covers expiry, secret refresh and removal. A graded lab follows the fourth part.

## Learning objectives

After this module you can:

- Explain the difference between a robot account and a user.
- Create a project robot account with the REST API and read its name and secret.
- Name the resources and actions a robot permission is made of.
- Explain the difference between a project robot and a system robot.
- Sign `oras` in with a robot account and prove what it may and may not do.
- Set an expiry, refresh a secret, and delete a robot account.

## Before you start

You need to know what a Harbor project and a role are, and how to call the REST API with `curl`.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. The `workstation` pod holds `harbor` (v0.0.27), `oras`, `curl` and `jq`. Harbor holds:

| Object | What it is |
| --- | --- |
| `admin` | The built-in system administrator, with the lab-only password `Harbor12345` |
| `alice` | A local user with the lab-only password `AlicePass1`, Project Admin of `web` |
| `web`, `api` | Two private projects, each with no artifacts yet |

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
