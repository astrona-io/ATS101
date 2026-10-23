# Solution: Keep A Project Within Its Storage Budget

Work the task yourself first. Running `astrona submit -c sections/section-020/module-01/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the quota is 20 MiB and refuses a 30 MiB push, `release-1.0` cannot be overwritten, and one run of the retention policy leaves exactly `build-4`, `build-5`, `build-6` and `release-1.0`. It runs the retention policy itself, for real.

## Step 1: Set the quota

Only a system administrator can set a quota. Sign the CLI in as `admin` and set 20 MiB:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
ws harbor quota update --project-name inventory --storage 20MiB
ws harbor quota list
```

The row for `inventory` shows a limit of 20 MiB, which is `20971520` bytes in the REST API.

## Step 2: Make releases immutable

Do this before the retention policy. The retention rule you write next keeps builds only, and immutability is what keeps `release-1.0`. Save this as `immutable-release.json`:

```json
{
  "disabled": false,
  "action": "immutable",
  "template": "immutable_template",
  "tag_selectors": [
    { "kind": "doublestar", "decoration": "matches", "pattern": "release-*" }
  ],
  "scope_selectors": {
    "repository": [
      { "kind": "doublestar", "decoration": "repoMatches", "pattern": "**" }
    ]
  }
}
```

Create it:

```sh
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects/inventory/immutabletagrules < immutable-release.json
```

## Step 3: Create the retention policy

The policy needs the project's numeric ID. Read it:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory | jq .project_id'
```

Save this as `retention-inventory.json` and replace `<PROJECT_ID>` with the number:

```json
{
  "algorithm": "or",
  "rules": [
    {
      "disabled": false,
      "action": "retain",
      "template": "latestPushedK",
      "params": { "latestPushedK": 3 },
      "tag_selectors": [
        { "kind": "doublestar", "decoration": "matches", "pattern": "build-*" }
      ],
      "scope_selectors": {
        "repository": [
          { "kind": "doublestar", "decoration": "repoMatches", "pattern": "**" }
        ]
      }
    }
  ],
  "trigger": { "kind": "Schedule", "settings": { "cron": "" } },
  "scope": { "level": "project", "ref": <PROJECT_ID> }
}
```

Create it, and read the policy ID back from the project:

```sh
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/retentions < retention-inventory.json
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory | jq .metadata.retention_id'
```

## Step 4: Check with a dry run

Start a dry run with the policy ID in place of `<RETENTION_ID>`, wait a few seconds, then read the newest execution and its tasks:

```sh
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' -d '{"dry_run":true}' https://harbor.localtest.me:8443/api/v2.0/retentions/<RETENTION_ID>/executions
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/retentions/<RETENTION_ID>/executions?page_size=1" | jq ".[0] | {id, status, dry_run}"'
```

Use the execution `id` to read the tasks:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/retentions/<RETENTION_ID>/executions/<EXECUTION_ID>/tasks | jq ".[] | {repository, total, retained}"'
```

The task for `app` looks at seven artifacts. The retention rule keeps three builds, and the immutable `release-1.0` is never deleted, so four artifacts stay after a real run. Do not start the real run; the grader does.

## Step 5: Check the quota and the immutable tag

Push a 30 MiB file and then `release-1.0` again; both must be refused:

```sh
echo Harbor12345 | ws oras login --registry-config /tmp/admin.json -u admin --password-stdin harbor.localtest.me:8443
ws sh -c 'cd /tmp && head -c 31457280 /dev/urandom > big.bin && oras push --registry-config /tmp/admin.json harbor.localtest.me:8443/inventory/blob:big big.bin'
ws sh -c 'cd /tmp && echo changed > note.txt && oras push --registry-config /tmp/admin.json harbor.localtest.me:8443/inventory/app:release-1.0 note.txt'
```

## Step 6: Submit

```sh
astrona submit -c sections/section-020/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Retention rule for `**`, newest 4 | It keeps `release-1.0` today only because it is new; after the next four builds, the release is deleted |
| No immutability, a second "always" rule for `release-*` | Retention keeps the release, but anyone with push rights can still overwrite it; the grader checks the overwrite |
| Delete `build-1` to `build-3` by hand | The next builds pile up again; the grader runs the policy, not your cleanup |
| Set the quota to `-1` | There is no limit at all |
