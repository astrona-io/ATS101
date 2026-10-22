# Solution: Repair Project Access For Three Teams

Work the task yourself first. Running `astrona submit -c sections/section-010/capstone/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks four things, each by acting as the user: `team-a` is private, `bob` reaches `team-b` only, `carol` is read-only on `team-b`, and `dan` can delete in `team-a` while `alice` cannot.

## Step 1: Read the current set-up

Sign the CLI in, then read both projects and their members through the REST API, which shows the visibility and each role as a number:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
echo Harbor12345 | ws harbor login https://harbor.localtest.me:8443 --username admin --password-stdin
for project in team-a team-b; do
  ws sh -c "curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/$project | jq -r '\"$project public=\" + .metadata.public'"
  ws sh -c "curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/$project/members | jq -r '.[] | [.entity_name, .role_id] | @tsv'"
done
```

Compare the output with the intended access. Remember the role numbers: 1 Project Admin, 2 Developer, 3 Guest, 4 Maintainer. Four things differ:

- `team-a` is public (`public=true`), so anyone can pull from it.
- `bob` is a member of `team-a` with role 1, Project Admin. He should have no access there.
- `carol` is a member of `team-b` with role 2, Developer, so she can push. She should be a Guest.
- `dan` is a member of `team-a` with role 2, Developer, so he cannot delete. Deleting artifacts needs Maintainer.

## Step 2: Make team-a private

```sh
ws harbor project config update team-a --public false
```

The project keeps its artifacts and members; only anonymous reads stop.

## Step 3: Remove bob from team-a

`bob` should have no access to `team-a`, so remove the membership instead of lowering the role. A Guest could still pull:

```sh
ws harbor project member delete team-a --username bob
```

His Developer membership of `team-b` is a different membership and stays.

## Step 4: Correct the two roles

`harbor project member update` takes the project, the member and the new role number. `carol` becomes Guest (3) in `team-b`, and `dan` becomes Maintainer (4) in `team-a`:

```sh
ws harbor project member update team-b carol --roleid 3
ws harbor project member update team-a dan --roleid 4
```

Do not raise `alice` to Maintainer. The task says she pushes and pulls, which is Developer, and the grader checks that she still cannot delete.

## Step 5: Prove the result

Delete an artifact as each of the two users in `team-a`. First push one as `admin`, then delete it as `alice` and as `dan`:

```sh
echo Harbor12345 | ws oras login --registry-config /tmp/admin.json -u admin --password-stdin harbor.localtest.me:8443
ws sh -c 'cd /tmp && date > note.txt && oras push --registry-config /tmp/admin.json harbor.localtest.me:8443/team-a/app:old note.txt'
ws curl -s -o /dev/null -w '%{http_code}\n' -u alice:AlicePass1 -X DELETE https://harbor.localtest.me:8443/api/v2.0/projects/team-a/repositories/app/artifacts/old
ws curl -s -o /dev/null -w '%{http_code}\n' -u dan:DanPass1 -X DELETE https://harbor.localtest.me:8443/api/v2.0/projects/team-a/repositories/app/artifacts/old
```

`alice` gets `403`, because a Developer may not delete, and `dan` gets `200`. Check `bob` and `carol` the same way with `oras`: `bob`'s pull from `team-a` fails, and `carol`'s pull from `team-b` works while her push fails.

## Step 6: Submit

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Lower `bob` to Guest in `team-a` | He can still pull every `team-a` image |
| Make `dan` Project Admin | He could also change members and delete the project |
| Delete and recreate `team-a` | Its artifacts are lost; the task forbids it |
| Make `carol` a Limited Guest of `team-a` too | She was never meant to see `team-a` |
