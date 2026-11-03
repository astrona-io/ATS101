# Summary

A Harbor quota is a limit on the storage a project may reference. Harbor does not measure disk space. Harbor core adds up the manifests and blobs that a project references, and the registry component stores each blob once.

The limit lives on the project. A system-wide default, stored as `storage_per_project`, is only copied into projects that Harbor creates after the default is set. Existing projects keep their own quota, and a project's own quota always wins. Only a system administrator can change a quota or the default, and a value of `-1` means unlimited.

Harbor counts a shared blob once per project. The same data pushed into two projects is charged to both, and a copy into another project raises the usage of the target. Harbor checks the limit when the manifest arrives, after the blobs are uploaded, so a push can fail at the end, and parallel pushes can overshoot slightly.

Usage can be read with `harbor quota list`, with the `/quotas` endpoint, and with a project's summary. Deleting an artifact lowers the usage that Harbor counts, while garbage collection removes the unused blobs from disk. A quota never deletes anything, so a project that is often full needs a retention policy as well.

- The default quota applies only to new projects.
- A quota counts blobs and manifests per project.
- Harbor refuses a push when the manifest arrives.
- Garbage collection frees disk space; deleting lowers counted usage.

<!-- astrona:playground:destroy -->
