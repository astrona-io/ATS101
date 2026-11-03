# Solution: Restrict Project Creation And Delegate Administration

Work the task yourself first. Running `astrona submit -c sections/section-010/module-02/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: `alice` is a system administrator and `bob` is not, only administrators can create projects, and `temp-user` is gone.

## Step 1: Make alice a system administrator

A user's administrator flag is changed with a separate request, by ID. Find the ID of `alice`:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/users/search?username=alice" | jq ".[] | {user_id, username, sysadmin_flag}"'
```

Save this as `sysadmin-true.json`:

```json
{ "sysadmin_flag": true }
```

Send it, using the number from the first command in place of `<USER_ID>`:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/users/<USER_ID>/sysadmin < sysadmin-true.json
```

Read the user again to check that `sysadmin_flag` is `true`.

## Step 2: Restrict project creation

Save this as `restrict-creation.json`:

```json
{ "project_creation_restriction": "adminonly" }
```

Send it:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < restrict-creation.json
```

Prove the effect. `bob` must receive 403 and `alice` must receive 201 for a new project:

```sh
ws curl -s -o /dev/null -w '%{http_code}\n' -u bob:BobPass1 -X POST -H 'Content-Type: application/json' -d '{"project_name":"bob-project"}' https://harbor.localtest.me:8443/api/v2.0/projects
ws curl -s -o /dev/null -w '%{http_code}\n' -u alice:AlicePass1 -X POST -H 'Content-Type: application/json' -d '{"project_name":"alice-project"}' https://harbor.localtest.me:8443/api/v2.0/projects
```

## Step 3: Delete temp-user

Find the ID of `temp-user` with the search from step 1, then delete it:

```sh
ws curl -s -o /dev/null -w '%{http_code}\n' -u admin:Harbor12345 -X DELETE https://harbor.localtest.me:8443/api/v2.0/users/<USER_ID>
```

Run `astrona submit` to grade the lab.
