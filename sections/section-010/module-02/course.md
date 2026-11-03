# Manage Local Users And System Administrators

Every access decision in Harbor starts with a user. Before a role or a project means anything, someone has to create the user, decide whether that user may administer the whole registry, and decide who may create projects. A registry where everyone can create projects and many people are administrators is hard to control and hard to audit.

A **local user** is an account that Harbor stores in its own database and checks with its own password. A **system administrator** is a user with the administrator flag, who may act on every project and on the system settings. Keep one sentence in mind for the whole module: **a user starts with no rights, the administrator flag is the only global right, and two system settings decide who may register and who may create projects.**

The module has four parts. **Local Users And Database Authentication** creates, lists and searches users. **System Administrators And Project Roles** compares the global flag with project roles. **System Settings That Control Tenancy** changes who may create projects and register. **Offboarding Users** removes access and deletes accounts. A graded lab follows the fourth part.

## Learning objectives

After this module you can:

- Create, list and search local users with the `harbor` CLI and the REST API.
- Name the fields of a user and which of them must be unique.
- Explain what the administrator flag allows that a Project Admin role does not.
- Grant and remove the administrator flag.
- Set `project_creation_restriction` and `self_registration` and prove their effect.
- Say which settings can no longer be changed after the authentication mode changes.
- Remove a user from projects and delete the account, and explain what Harbor keeps.

## Before you start

You need Kubernetes basics (`kubectl exec`) and the idea of a project and a member role. Harbor is already running.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. The `workstation` pod holds `harbor` (v0.0.27), `oras`, `curl` and `jq`. Harbor holds:

| Object | What it is |
| --- | --- |
| `admin` | The built-in system administrator, with the lab-only password `Harbor12345` |
| `alice`, `bob`, `temp-user` | Local users with the lab-only passwords `AlicePass1`, `BobPass1` and `TempPass1` |

Project creation is open to everyone at the start. Every command in the parts runs in the workstation, and `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
