# How Harbor Counts Storage

A quota of 20 MiB sounds like 20 MiB of files, but Harbor does not add up file sizes. It adds up the blobs and manifests that a project references. This part explains what those are, why two artifacts can share storage, and why the same data pushed to two projects counts twice.

## Blobs and manifests

An image or an OCI artifact consists of **blobs** and one **manifest**. A blob is a file stored by its digest, for example a layer of an image. A manifest is a small JSON document that lists the blobs of the artifact. The registry component stores each blob once on disk, identified by its digest, and Harbor core keeps the accounting.

When a client pushes, it uploads the blobs first and the manifest last. Harbor core receives the manifest request, adds the sizes of the manifest and of the blobs that are new to the project, and compares the total with the quota. This is why a push can fail at the very end: the blobs are already uploaded when Harbor decides that the manifest does not fit.

## Shared blobs count once per project

If two artifacts in one project use the same blob, Harbor counts the blob once for that project. Push a file as `inventory/app:v2` and the same file under a second tag:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'cd /tmp && head -c 3145728 /dev/urandom > shared.bin && oras login -u admin -p Harbor12345 harbor.localtest.me:8443 && oras push harbor.localtest.me:8443/inventory/app:v2 shared.bin && oras push harbor.localtest.me:8443/inventory/app:v3 shared.bin'
kubectl -n workstation exec -it deploy/workstation -- harbor quota list
```

The usage of `inventory` grows by about 3 MiB, not 6 MiB. The two pushes use the same blob, and the second push only adds a small manifest. Only the configuration blob that `oras` creates for each artifact and the manifest are new.

## Two projects, two counts

The sharing is scoped to one project. Create a second project and push the same file there. Save this as `project-copy.json`:

```json
{ "project_name": "copy-test", "metadata": { "public": "false" }, "storage_limit": -1 }
```

```sh
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects < project-copy.json
ws sh -c 'cd /tmp && oras push harbor.localtest.me:8443/copy-test/app:v1 shared.bin'
kubectl -n workstation exec -it deploy/workstation -- harbor quota list
```

The usage of `copy-test` is also about 3 MiB. The registry stores the blob once on disk, but each project is charged for it. The sum of all project usages can therefore be larger than the disk space in use.

## Copying and retagging

Retagging inside one project does not change the usage, because no new blob enters the project. Copying an artifact into another project does change it: the target project is now charged for the blobs of the artifact. A user who copies a large image into a project with a small quota can therefore trigger a refusal in the target project, not in the source.

Helm chart sizes are not counted. Harbor documents this limit, so do not use a quota to control how many charts a team stores.

## Concurrent pushes

Harbor accepts a push when the manifest arrives and the quota still has room at that moment. Two clients that push at the same time can both pass the check, so a project can end slightly above its limit. A quota is a strong guard, not an exact counter under load.

You now know what Harbor counts and when it checks the limit: per project, with shared blobs counted once, at the arrival of the manifest. The next part reads these numbers directly instead of inferring them from pushes.

## Common pitfalls

> [!WARNING]
> - **Adding up file sizes to predict usage.** Harbor charges blobs per project, and the manifest and configuration blob add a little.
> - **Expecting a cross-project copy to cost nothing.** The target project is charged for the blobs.
> - **Treating the sum of project usages as disk usage.** The same blob can be charged to several projects.
> - **Expecting an exact limit with parallel pushes.** The check runs when the manifest arrives.
