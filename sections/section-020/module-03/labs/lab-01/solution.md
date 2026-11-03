# Solution: Combine Two Retention Rules With Immutability

Work the task yourself first. Running `astrona submit -c sections/section-020/module-03/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the policy has two rules and no schedule and `release-*` is immutable, `release-1.0` cannot be overwritten, and one run leaves `web` with `build-4`, `build-5` and `release-1.0` and `api` with all four builds.

## Step 1: Make releases immutable

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
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects/catalog/immutabletagrules < immutable-release.json
```

## Step 2: Create the retention policy

Read the project ID:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/catalog | jq .project_id'
```

Save this as `retention-catalog.json` and replace `<PROJECT_ID>` with the number:

```json
{
  "algorithm": "or",
  "rules": [
    {
      "disabled": false,
      "action": "retain",
      "template": "latestPushedK",
      "params": { "latestPushedK": 2 },
      "tag_selectors": [
        { "kind": "doublestar", "decoration": "matches", "pattern": "build-*" }
      ],
      "scope_selectors": {
        "repository": [
          { "kind": "doublestar", "decoration": "repoMatches", "pattern": "**" }
        ]
      }
    },
    {
      "disabled": false,
      "action": "retain",
      "template": "always",
      "tag_selectors": [
        { "kind": "doublestar", "decoration": "matches", "pattern": "**" }
      ],
      "scope_selectors": {
        "repository": [
          { "kind": "doublestar", "decoration": "repoMatches", "pattern": "api" }
        ]
      }
    }
  ],
  "trigger": { "kind": "Schedule", "settings": { "cron": "" } },
  "scope": { "level": "project", "ref": <PROJECT_ID> }
}
```

The first rule keeps two builds everywhere. The second keeps everything in `api`. Rules combine with OR, so an artifact in `api` survives because the second rule keeps it. Create the policy:

```sh
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/retentions < retention-catalog.json
```

## Step 3: Check with a dry run

Read the retention ID from `metadata.retention_id` of the project, then start a dry run with `{"dry_run":true}` against `/retentions/<RETENTION_ID>/executions` and read its tasks. Do not start a real run. Run `astrona submit` to grade the lab.
