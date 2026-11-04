# Robot Accounts And Their Names

A pipeline needs a name and a secret before it can sign in. This part explains how a robot account differs from a user, creates a robot account for one project, and reads the name and secret that Harbor returns.

## Why not a user

A user account is meant for a person. It has a password that people reuse, an email address and, in LDAP or OIDC mode, a link to a directory. If a pipeline signs in as `alice`, then every action in the audit log looks like Alice did it, the pipeline has all of Alice's roles, and the pipeline breaks when Alice's password changes or the account is deleted.

A robot account avoids all three problems. It has a name that says what it is for, it holds a list of permissions that is separate from any person, and it can be created, rotated and deleted without touching a user. A robot works in every authentication mode, because Harbor checks its secret itself and never asks the directory or the identity provider.

## Two levels

Harbor has two levels of robot account. A **project robot account** belongs to one project and can only have permissions in that project. A **system robot account** belongs to the registry and can have permissions in several projects, or in all of them, and can also have system-wide permissions such as creating projects. This part creates a project robot, and the next part creates a system robot.

## Creating a project robot

The API call is `POST /robots`. The body names the robot, sets its level and lists the permissions. Save this as `robot-ci.json`:

<!-- astrona:playground:renew -->

```json
{
  "name": "ci",
  "description": "Pushes images from the build pipeline",
  "level": "project",
  "duration": 30,
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

The `duration` is the lifetime in days. The value `-1` means that the robot never expires. The `namespace` is the project name. Send the file as the administrator:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -s -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/robots < robot-ci.json
```

The answer is a short JSON object with the numeric `id`, the `name`, the `secret` and the `expires_at` time.

## The name

The name in the answer is not `ci`. Harbor builds the full name from a prefix, the project name and your name, and joins them with a plus sign: `robot$web+ci`. The prefix is `robot$` by default and an administrator can change it with the configuration key `robot_name_prefix`. A system robot has no project part, so its name is the prefix plus your name, for example `robot$nightly`.

The dollar sign is part of the name. In a shell, quote the name with single quotes, because `$web` would otherwise expand to an empty variable and the sign-in would fail with an unknown user.

## The secret

The secret is a random string of letters and digits. Harbor shows it once, in the answer to the create call, and stores only a hash. If you lose it, you cannot read it again; you must replace it with a new secret, as the last part of this module shows. Copy the secret into your pipeline's secret store at once, and never write it in a repository.

The robot now exists. List the robots to see it, without any secret:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/robots?page_size=100" | jq -r ".[] | [.id, .name, .level, .duration, .disable] | @tsv"'
```

The list shows one line with the ID, the name `robot$web+ci`, the level `project`, the duration `30` and `disable` as `false`.

You can now create a project robot account and read its full name and secret. The open question is what the list of permissions means, and how exact it must be.

## Common pitfalls

> [!WARNING]
> - **Using the short name to sign in.** The user name is the full name, such as `robot$web+ci`.
> - **Leaving the dollar sign unquoted.** The shell expands `$web` and the sign-in fails.
> - **Losing the secret.** Harbor shows it once; the only fix is to refresh it.
> - **Creating a robot with `duration` `-1` for convenience.** A robot that never expires is a secret that nobody reviews.
