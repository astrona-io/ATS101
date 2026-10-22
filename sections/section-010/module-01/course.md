# Isolate Teams With Projects And Roles

Two teams share one Harbor. The first team pushes images to `team-a`, the second to `team-b`. Nothing stops the first team from pulling the second team's images, or even overwriting them, unless someone set up the projects with care. A registry that leaks one team's images to another is a security problem, and a registry that lets anyone overwrite a tag is an operations problem.

A **project** is Harbor's unit of access control: every repository lives in exactly one project, and the project decides who may see it. A **member** is a user or a group added to a project, and the member's **role** decides what that member may do there. Keep one sentence in mind for the whole module: **a private project shows nothing to anyone who is not a member, and each member gets the smallest role that lets them work.**

The module has three parts. **Projects, Public And Private** shows what an anonymous client can do in each kind of project. **Member Roles And What Each One May Do** walks through the five roles and proves the difference between two of them with a push. **Adding Members With The harbor CLI** creates projects and members from the command line and reads them back through the REST API. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Explain what a Harbor project is and which repositories belong to it.
- Create a public and a private project, and say what an anonymous client can do in each.
- Name the five project roles and say what each one may do.
- Explain why some settings, such as storage quotas, belong to the system administrator only.
- Add, change and remove project members with the `harbor` CLI.
- Read members and roles through the REST API, where each role has a number.
- Prove a user's access with a real push and pull as that user.

## Before you start

You need Kubernetes basics: `kubectl exec`, namespaces and pods. You should know what a container image, a repository, a tag and a digest are. This module does not teach Harbor's installation; Harbor is already running.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** in the namespace `harbor`, at the address `https://harbor.localtest.me:8443`. The `workstation` pod holds the client tools: `harbor` (the Harbor command-line tool, v0.0.27), `oras` (a client that pushes and pulls any file as an OCI artifact), `curl` and `jq`. It already trusts Harbor's certificate. Harbor holds:

| Object | What it is |
| --- | --- |
| `admin` | The system administrator, with the lab-only password `Harbor12345` |
| `alice`, `bob`, `carol` | Local users with the lab-only passwords `AlicePass1`, `BobPass1` and `CarolPass1`; no project memberships yet |
| `inventory` | A private project with one small artifact, `inventory/notes:v1` |

Every command in the parts runs in the workstation, and `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
