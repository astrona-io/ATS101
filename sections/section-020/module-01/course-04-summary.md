# Summary

A registry project only grows unless something removes old artifacts. Harbor gives three tools for this, and each has one job.

A storage quota is the most bytes a project may store. Harbor counts storage from the blobs pushed into the project, and a blob shared by several artifacts counts once per project. By default there is no limit, shown as `-1`, and only a system administrator can set one. A push over the quota is refused, sometimes only at the end when the manifest arrives. A quota never deletes anything, and deleted artifacts give their space back only after garbage collection.

A tag retention rule says which artifacts to keep. It selects repositories and tags with matching or excluding patterns, and a template decides how many to keep: the newest pushed or pulled, those from the last days, or all. Rules combine with OR, a project may have up to 15, and they share one schedule. Everything no rule keeps is deleted when the policy runs. A real run cannot be undone, so a dry run comes first; its tasks show, per repository, how many artifacts there are and how many would be kept.

A tag immutability rule makes matching tags impossible to overwrite, re-tag or delete, even for the system administrator. A retention run never deletes an immutable artifact. That makes the usual combination simple: retention keeps the newest builds, immutability keeps every release, and the quota catches whatever the rules miss. The key facts to remember are these:

- Retention rules say what to keep, never what to delete.
- Always read a dry run before a real retention run.
- Immutable tags survive retention and refuse every overwrite.
- Only a system administrator sets a quota; garbage collection gives the space back.

<!-- astrona:playground:destroy -->
