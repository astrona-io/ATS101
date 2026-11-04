# Solution: Create And Clean Up Robot Accounts

Work the task yourself first. Running `astrona submit -c sections/section-010/module-04/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the permissions and lifetime of `robot$web+ci`, that `robot$web+legacy` is gone, and that `ci` works only in `web`.

## Step 1: Create the robot

Look at what exists first:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/robots?page_size=100" | jq ".[] | {id, name, duration, level}"'
```

The list shows `robot$web+legacy` with the duration `-1`. Save this as `robot-ci.json`:

```json
{
  "name": "ci",
  "description": "web pipeline",
  "duration": 30,
  "level": "project",
  "disable": false,
  "permissions": [
    {
      "kind": "project",
      "namespace": "web",
      "access": [
        { "resource": "repository", "action": "push" },
        { "resource": "repository", "action": "pull" }
      ]
    }
  ]
}
```

Send it:

```sh
ws curl -s -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/robots < robot-ci.json
```

The answer holds the full name `robot$web+ci` and the secret. Copy the secret now, because Harbor does not show it again.

## Step 2: Delete the legacy robot

Find the ID of `robot$web+legacy` in the list from step 1, and delete it:

```sh
ws curl -s -o /dev/null -w '%{http_code}\n' -u admin:Harbor12345 -X DELETE https://harbor.localtest.me:8443/api/v2.0/robots/<ROBOT_ID>
```

Replace `<ROBOT_ID>` with the number from the list. List the robots again to check that only `robot$web+ci` is left.

## Step 3: Prove the limits

Sign `oras` in with the full name and the secret, then push to `web` and to `api`:

```sh
ws oras login --registry-config /tmp/ci.json -u 'robot$web+ci' -p '<SECRET>' harbor.localtest.me:8443
ws sh -c 'cd /tmp && date > note.txt && oras push --registry-config /tmp/ci.json harbor.localtest.me:8443/web/app:ci note.txt'
ws sh -c 'cd /tmp && oras push --registry-config /tmp/ci.json harbor.localtest.me:8443/api/app:ci note.txt'
```

The push to `web` succeeds and the push to `api` is refused. Run `astrona submit` to grade the lab.
