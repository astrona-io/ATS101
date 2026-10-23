# Solution: Stop Retention From Deleting Releases

Work the task yourself first. Running `astrona submit -c sections/section-020/capstone/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks four things: the quota is 50 MiB and takes a 10 MiB push, release tags are immutable, the policy has no schedule, and one real run leaves the three newest builds and both releases.

## Step 1: Read the policy and the quota

Find the policy ID through the project, then read the policy:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory | jq "{project_id, retention_id: .metadata.retention_id}"'
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/retentions/<RETENTION_ID> | jq "{trigger, rules: [.rules[] | {template, params, tags: .tag_selectors[0].pattern}]}"'
ws harbor quota list
```

The policy has one rule: template `latestPushedK` with `1`, for the tag pattern `**`. It keeps a single artifact, the newest one, and deletes everything else, both releases included. Its trigger has a `cron` schedule, so it would run on its own. The quota of `inventory` is 5 MiB, far too small for a 10 MiB push.

A dry run proves the damage without causing it. Start one and read the task counts, as in the module: the task for `app` looks at eight artifacts and keeps one.

## Step 2: Raise the quota

```sh
ws harbor quota update --project-name inventory --storage 50MiB
```

## Step 3: Protect the releases

Save this as `immutable-release.json`:

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

Both releases are now immutable, so no retention run and no push can remove or change them.

## Step 4: Correct the policy and remove the schedule

Change the existing policy with a `PUT` to its own ID. Save this as `retention-inventory.json`, with `<RETENTION_ID>` and `<PROJECT_ID>` replaced by the numbers from step 1:

```json
{
  "id": <RETENTION_ID>,
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

Update the policy:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/retentions/<RETENTION_ID> < retention-inventory.json
```

The empty `cron` removes the schedule. A new dry run now keeps three builds, and the immutable releases are never deleted.

## Step 5: Check and submit

Push a 10 MiB file, then try to push `release-1.0` again; the first works and the second is refused:

```sh
echo Harbor12345 | ws oras login --registry-config /tmp/admin.json -u admin --password-stdin harbor.localtest.me:8443
ws sh -c 'cd /tmp && head -c 10485760 /dev/urandom > ten.bin && oras push --registry-config /tmp/admin.json harbor.localtest.me:8443/inventory/blob:ten ten.bin'
ws sh -c 'cd /tmp && echo changed > note.txt && oras push --registry-config /tmp/admin.json harbor.localtest.me:8443/inventory/app:release-1.0 note.txt'
astrona submit -c sections/section-020/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Delete the retention policy | The project never cleans up again; the grader needs a policy to run |
| Set the quota to `-1` | There is no limit at all; the task asks for 50 MiB |
| Change the rule to keep the newest 5 of `**` | Today it keeps both releases; after a few more builds it deletes them |
| Disable the schedule and leave the rule | The next time someone starts the policy by hand, it deletes everything but one artifact |
