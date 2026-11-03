# Offboarding Users

People leave teams and companies. A registry that keeps their access open is a risk, and a registry that breaks the pipelines they built is a problem. This part removes a user in two steps, first the access and then the account, and shows what Harbor keeps.

## Remove access first

A user has two kinds of access: memberships in projects and the administrator flag. Remove both before deleting the account, so that you see what the person could reach. List the memberships of a project and remove one. The role numbers are in the earlier lists of this course; here you only need the membership ID:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members | jq ".[] | {id, entity_name, role_name}"'
ws curl -s -o /dev/null -w '%{http_code}\n' -u admin:Harbor12345 -X DELETE https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members/<MEMBER_ID>
```

Replace `<MEMBER_ID>` with the `id` of the membership. The `id` is the ID of the membership, not of the user. The answer is 200. The CLI command `harbor project member delete` does the same work.

## Delete the account

Delete the user by ID with the REST API:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/users/search?username=temp-user" | jq ".[] | {user_id, username}"'
ws curl -s -o /dev/null -w '%{http_code}\n' -u admin:Harbor12345 -X DELETE https://harbor.localtest.me:8443/api/v2.0/users/<USER_ID>
```

Harbor answers 200. The user can no longer sign in. Harbor does not erase the row: it marks the user as deleted and renames the username and the email with a suffix that contains the user ID, so that the name becomes free for a new account. Search for the name again and the old account no longer appears under its original name.

## What stays

The artifacts that the user pushed stay in their projects, because artifacts belong to projects and not to people. Audit log entries stay with the name that was used at the time. Robot accounts that the user created belong to the project or the system and keep working until someone deletes them; a CI pipeline that used the user's own password stops working at once. Check for such pipelines before you delete.

## What Harbor refuses

Harbor refuses to delete the built-in `admin` account. Remove the flag from a person's personal account instead of sharing `admin`, so that every action in the log has a name.

## A short offboarding checklist

1. List the projects where the user is a member and remove each membership.
2. Remove the administrator flag if the user has it.
3. Check which pipelines use the user's credentials and move them to a robot account.
4. Delete the user.
5. Search for the name and read the audit log for the last actions.

You now know the whole life of a local user: create, grant, restrict and remove. The graded lab asks you to apply these steps together.

## Common pitfalls

> [!WARNING]
> - **Deleting a user before moving their CI credentials.** The pipeline fails the next time it signs in.
> - **Expecting the artifacts of a deleted user to disappear.** They belong to the project.
> - **Using the membership ID as the user ID.** They are different numbers.
> - **Sharing the `admin` account.** The log then shows `admin` for every action.

## Your mission: Restrict Project Creation And Delegate Administration

You can now create and find users, grant and remove the administrator flag, restrict project creation and delete an account. The graded lab asks you to make one user an administrator, close project creation to everyone else and delete an old account.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-101-playground-010-02
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/section-010/module-02/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-02/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-101-lab-010-02
astrona start ats-101-playground-010-02
```
