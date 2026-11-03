# Quotas And Deletion

A project that reaches its quota needs room. There are two ways to make room: raise the limit, or delete artifacts. This part shows what a refused push looks like, what deleting does to the usage, and what garbage collection does to the disk.

## What a refused push looks like

Set a small quota on `inventory` and push a file that does not fit:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
ws harbor quota update --project-name inventory --storage 5MiB
ws sh -c 'cd /tmp && head -c 8388608 /dev/urandom > big.bin && oras login -u admin -p Harbor12345 harbor.localtest.me:8443 && oras push harbor.localtest.me:8443/inventory/app:big big.bin'
```

The `oras push` command fails. The error names the storage resource, the usage that the push would reach and the configured upper limit. Harbor core sends this refusal when the manifest arrives, so the client has already uploaded the blob. The refused artifact does not exist in the project, and it is not counted.

## Making room by deleting

Push a file that fits, check the usage, delete the artifact through the REST API (the reference of an artifact can be its tag) and check again:

```sh
ws sh -c 'cd /tmp && head -c 2097152 /dev/urandom > small.bin && oras push harbor.localtest.me:8443/inventory/app:small small.bin'
kubectl -n workstation exec -it deploy/workstation -- harbor quota list
ws curl -s -u admin:Harbor12345 -X DELETE https://harbor.localtest.me:8443/api/v2.0/projects/inventory/repositories/app/artifacts/small
kubectl -n workstation exec -it deploy/workstation -- harbor quota list
```

The usage rises by about 2 MiB after the push. After the delete, Harbor lowers the usage of the project, because the project no longer references the blob. Check the numbers in your playground instead of trusting this sentence: the second `quota list` should show less usage than the first.

## Disk space is a different number

The quota is an accounting number kept by Harbor core. The blobs are stored by the registry component. When you delete an artifact, Harbor removes the manifest, but the registry keeps the blob file until garbage collection runs. **Garbage collection** is a Harbor job that finds blobs which no artifact references and deletes them from storage. A quota therefore tells you what a project is allowed to reference, and garbage collection tells the registry which files it may delete.

Garbage collection is a system administrator task, scheduled or started by hand, and it belongs to the operations of Harbor itself. For this module, remember the split: deleting changes the quota usage, and garbage collection changes the disk.

## Quota and retention together

A quota refuses new pushes, and it never deletes. If a project hits its limit every week, raising the quota only delays the problem. A tag retention policy removes old artifacts on a schedule, so the usage falls without a person doing it. Use the quota as the hard limit and retention as the routine cleanup, in that order of importance: the quota protects the system, and retention keeps the project useful.

## Reading a full project

When a team reports that pushes fail, follow three steps. First read the quota of the project and compare `used` with `hard`. Second, if the project is full, list the repositories and artifacts and ask which are old. Third, either delete or retain by rule, or raise the limit through a system administrator. Do not start by raising the limit; a full project is often a missing retention rule.

You now know how to read a refusal, what deletion does to usage, and why the disk number differs from the quota number. You can set a default quota, create a project that inherits it and correct the limit of an existing project.

## Common pitfalls

> [!WARNING]
> - **Expecting a quota to delete old artifacts.** It only refuses new ones.
> - **Expecting the disk to shrink after a delete.** Only garbage collection removes the blob files.
> - **Raising the limit every time a project is full.** Add a retention rule instead.
> - **Reading a refused push as a network error.** Read the error text; it names the limit.

## Your mission: Give New Projects A Default Quota

You can now set a default quota, explain why it affects only new projects, and change the quota of an existing project. The graded lab asks you to put a default in place, create a project that inherits it and correct a quota that is too large.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-101-playground-020-02
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/section-020/module-02/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-02/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-101-lab-020-02
astrona start ats-101-playground-020-02
```
