# Understand Quota Accounting In Depth

A storage quota looks simple until a push is refused with 5 MiB of free space, or a project reports more usage than the files you pushed. Harbor does not count disk space. It counts the blobs and manifests that each project references, and it applies a limit per project. To predict what a quota will do, you need to know exactly what Harbor counts, when it counts, and who may change the limit.

A **quota** is the largest amount of storage a project may use. A **default quota** is the limit that Harbor gives to every project created after the default is set. Keep one sentence in mind for the whole module: **Harbor counts each blob once per project, applies the limit when the manifest arrives, and only a system administrator can change a limit.**

The module has four parts. **Default Quotas And Project Quotas** shows where the default lives and why it only affects new projects. **How Harbor Counts Storage** explains blobs, manifests, shared layers and copies between projects. **Reading Quota Usage** reads usage with the `harbor` CLI and the REST API. **Quotas And Deletion** shows what happens to usage when you delete artifacts and what garbage collection does. A graded lab follows the fourth part.

## Learning objectives

After this module you can:

- Set the default storage quota and say which projects it affects.
- Explain why a project's own quota wins over the default.
- Describe how Harbor counts blobs and manifests, and why a shared layer counts once per project.
- Explain why copying an artifact into another project raises that project's usage.
- Read the used and hard values of a quota with the `harbor` CLI and the REST API.
- Explain why a push can be refused at the end, when the manifest arrives.
- Explain what garbage collection frees and why a quota never deletes anything.

## Before you start

You need to know what a Harbor project is and what a blob, a manifest and a tag are. Harbor is already running; this module does not teach its installation.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** at `https://harbor.localtest.me:8443`. The `workstation` pod holds the client tools: `harbor` (v0.0.27), `oras`, `curl` and `jq`. Harbor holds:

| Object | What it is |
| --- | --- |
| `admin` | The system administrator, with the lab-only password `Harbor12345` |
| `inventory` | A private project with a storage quota of 100 MiB and the artifact `inventory/app:v1` |

Every command in the parts runs in the workstation, and `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
