# Solution: Give New Projects A Default Quota

Work the task yourself first. Running `astrona submit -c sections/section-020/module-02/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the default quota is 15 MiB, `reports` has a 15 MiB quota and refuses a 20 MiB push, and `inventory` has a 40 MiB quota.

## Step 1: Set the default quota

The default lives in the system configuration as `storage_per_project`, in bytes. 15 MiB is 15728640 bytes. Save this as `default-quota.json`:

```json
{ "storage_per_project": 15728640 }
```

Send it:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < default-quota.json
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq .storage_per_project'
```

The second command shows the new value. A default applies only to projects created after the change, which is why the order of the steps matters.

## Step 2: Create the project

The `harbor project create` command needs `--storage-limit`, and a value such as `-1` would set the quota on the project itself, so the default would not apply. Create the project through the REST API and leave `storage_limit` out. Save this as `project-reports.json`:

```json
{ "project_name": "reports", "metadata": { "public": "false" } }
```

Create it and read its quota:

```sh
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects < project-reports.json
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
wst harbor quota list
```

The row for `reports` shows a limit of 15 MiB. If it shows no limit, you created the project before you changed the default; delete it and create it again.

## Step 3: Change the quota of inventory

```sh
ws harbor quota update --project-name inventory --storage 40MiB
wst harbor quota list
```

An existing project never follows the default, so you set its quota yourself. Run `astrona submit` to grade the lab.
