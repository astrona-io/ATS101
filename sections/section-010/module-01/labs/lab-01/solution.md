# Solution: Isolate Two Teams With Projects And Roles

Work the task yourself first. Running `astrona submit -c sections/section-010/module-01/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks four things: both projects are private, every user has exactly the role the task needs, each team member can push only to their own project, and `carol` can pull from both and push to neither. It proves each point by pushing and pulling as the user.

## Step 1: Sign the CLI in

Define the helper and sign the `harbor` CLI in as the system administrator:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
echo Harbor12345 | ws harbor login https://harbor.localtest.me:8443 --username admin --password-stdin
ws harbor project list
```

The list shows only `library`. The two team projects do not exist yet.

## Step 2: Create two private projects

`harbor project create` makes a private project unless you pass `--public`, and private is what the task asks for:

```sh
ws harbor project create team-a
ws harbor project create team-b
ws harbor project view team-a -o json
```

The `metadata` of the project holds `"public": "false"`. Do not pass `--public`: a public project lets anyone pull without signing in.

## Step 3: Give each user the smallest role

The task needs push and pull for the team members, which is Developer, and pull only for the auditor, which is Guest. Maintainer and Project Admin would also work for pushing, but they allow deleting artifacts and managing members, which the task does not need:

```sh
ws harbor project member create team-a --username alice --role Developer
ws harbor project member create team-b --username bob --role Developer
ws harbor project member create team-a --username carol --role Guest
ws harbor project member create team-b --username carol --role Guest
```

Read the result back through the REST API, which shows each role as a number (2 for Developer, 3 for Guest):

```sh
for project in team-a team-b; do
  ws sh -c "curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/$project/members | jq -r '.[] | [\"$project\", .entity_name, .role_id] | @tsv'"
done
```

`team-a` lists `admin 1`, `alice 2` and `carol 3`; `team-b` lists `admin 1`, `bob 2` and `carol 3`. `admin` is there because the creator of a project becomes its Project Admin.

## Step 4: Prove the isolation

Push one small file as each team member to their own project, then try the other project:

```sh
echo AlicePass1 | ws oras login --registry-config /tmp/alice.json -u alice --password-stdin harbor.localtest.me:8443
echo BobPass1 | ws oras login --registry-config /tmp/bob.json -u bob --password-stdin harbor.localtest.me:8443
ws sh -c 'cd /tmp && date > note.txt && oras push --registry-config /tmp/alice.json harbor.localtest.me:8443/team-a/app:alice note.txt'
ws sh -c 'cd /tmp && oras push --registry-config /tmp/bob.json harbor.localtest.me:8443/team-b/app:bob note.txt'
ws sh -c 'cd /tmp && oras push --registry-config /tmp/alice.json harbor.localtest.me:8443/team-b/app:alice note.txt'
```

The first two pushes succeed. The third fails, because `alice` is not a member of `team-b`.

## Step 5: Prove the auditor is read-only

Sign `oras` in as `carol`, pull from both projects, and try one push:

```sh
echo CarolPass1 | ws oras login --registry-config /tmp/carol.json -u carol --password-stdin harbor.localtest.me:8443
ws sh -c 'mkdir -p /tmp/pull && cd /tmp/pull && oras pull --registry-config /tmp/carol.json harbor.localtest.me:8443/team-a/app:alice'
ws sh -c 'mkdir -p /tmp/pull && cd /tmp/pull && oras pull --registry-config /tmp/carol.json harbor.localtest.me:8443/team-b/app:bob'
ws sh -c 'cd /tmp && oras push --registry-config /tmp/carol.json harbor.localtest.me:8443/team-a/app:carol note.txt'
```

Both pulls succeed and the push fails, because a Guest has no push permission.

## Step 6: Submit

```sh
astrona submit -c sections/section-010/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Make the projects public so `carol` can read them | Anyone, even without signing in, can pull every image; the grader refuses it |
| Give `alice` and `bob` Maintainer or Project Admin | It works for pushing, but they can delete artifacts or change members; the grader checks the exact role |
| Make `carol` a system administrator | She could push and change every project in Harbor |
| Put both teams in one project | Nothing keeps the teams apart any more |

## Practice on your own

- Add `alice` to `team-b` as Limited Guest and compare what she can read with what `carol` can read.
- Remove `carol` from `team-a` and check that her pull is refused at once.
- Read the members of `team-a` with `ws harbor project member list team-a` and match each row to the JSON from the REST API.
