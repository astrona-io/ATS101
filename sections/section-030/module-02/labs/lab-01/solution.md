# Solution: Give Two Keycloak Groups Different Roles

Work the task yourself first. Running `astrona submit -c sections/section-030/module-02/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the two group roles in `reports`, the admin group, and what `alice` and `carol` can do.

## Step 1: Add the two groups

An OIDC group has the group type `3`. The role IDs are `2` for Developer and `3` for Guest. Save this as `member-writers.json`:

```json
{ "role_id": 2, "member_group": { "group_name": "report-writers", "group_type": 3 } }
```

Save this as `member-readers.json`:

```json
{ "role_id": 3, "member_group": { "group_name": "report-readers", "group_type": 3 } }
```

Send both and read the member list back:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -s -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects/reports/members < member-writers.json
ws curl -s -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects/reports/members < member-readers.json
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/reports/members | jq -r ".[] | [.entity_name, .entity_type, .role_id] | @tsv"'
```

The list has two lines with the type `g`, role `2` for `report-writers` and role `3` for `report-readers`.

## Step 2: Set the admin group

The admin group is an OIDC setting. Save this as `admin-group.json`:

```json
{ "oidc_admin_group": "platform-admins" }
```

Send it:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < admin-group.json
```

Read the setting back with `GET /configurations` and `jq -r .oidc_admin_group.value`. Harbor gives the administrator right to `bob` per session, when he signs in with the group in his token, so the proof is a new sign-in by `bob`.

## Step 3: Prove the roles

Harbor reads the groups at sign-in, so the users must sign in after your change. In a browser with the port-forwards from the playground overview, sign in as `alice`, copy her CLI secret from the user profile, and push:

```sh
ws oras login --registry-config /tmp/alice.json -u alice -p '<CLI_SECRET>' harbor.localtest.me:8443
ws sh -c 'cd /tmp && date > note.txt && oras push --registry-config /tmp/alice.json harbor.localtest.me:8443/reports/app:alice note.txt'
```

The push succeeds. Do the same for `carol`: her pull of `reports/app:seed` works and her push is refused.

Run `astrona submit` to grade the lab.
