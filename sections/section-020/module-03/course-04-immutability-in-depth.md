# Immutability Rules In Depth

Retention decides what is kept, and it still allows a person to overwrite a tag. Some tags, such as releases, must never change. An immutability rule makes that a rule of the project. This part writes the rules, shows what they refuse and explains how they work with retention.

## What a rule forbids

An **immutability rule** selects tags by repository and tag patterns, in the same way as retention. A tag that matches cannot be overwritten, re-tagged to another artifact or deleted. This holds for every user, including the system administrator. A project can have up to 15 rules, and a tag is immutable if any rule matches it.

The rule has the template `immutable_template` and the action `immutable`. Create one for releases:

<!-- astrona:playground:renew -->

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

Save this as `immutable-release.json` and send it:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects/catalog/immutabletagrules < immutable-release.json
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/catalog/immutabletagrules | jq ".[] | {id, disabled, tag_selectors}"'
```

The second command lists the rules and their IDs. Change or remove a rule with `PUT` or `DELETE` on `/projects/catalog/immutabletagrules/<ID>`.

## Proving it

Push `release-1.0` again with a new payload. The push is refused, and the artifact stays as it was:

```sh
ws sh -c 'cd /tmp && echo changed > payload.txt && oras login -u admin -p Harbor12345 harbor.localtest.me:8443 && oras push harbor.localtest.me:8443/catalog/web:release-1.0 payload.txt'
```

The push of the existing tag fails with a conflict. A new tag such as `release-1.1` is allowed, because it does not exist yet. Immutability protects the tag, not the repository.

## Immutability and retention

A retention run does not delete an immutable artifact. Combine the two: a retention rule that manages `build-*`, and an immutability rule that protects `release-*`. If you protect with a retention rule only, nothing stops a person from overwriting the tag. If you protect with immutability only, retention still cleans up the builds. Use both, and leave the releases out of retention rules.

An immutability rule is not a rule about how long to keep. If the only reason a release exists is that nobody deleted it, add a rule that says so, so that the intent is written in the project.

## Other operations that meet an immutable tag

A tag copy into the project that would overwrite an immutable tag is refused. A replication that pulls an artifact with an immutable tag into the project fails for that tag when the content differs, while other tags still replicate. Check the replication execution logs after you add a rule to a project that receives replicated content.

## Design advice

Keep patterns narrow and name tags by convention, for example `release-*` for releases and `build-*` for builds. A pattern like `**` makes every tag immutable, including `latest`, which blocks every push to it. If a team needs a moving tag such as `stable`, do not match it.

You now know every part of the rules that keep a project tidy and safe: templates, selectors, runs, schedules and immutability. The lab puts them together.

## Common pitfalls

> [!WARNING]
> - **Making `**` immutable.** Even `latest` can no longer be pushed again.
> - **Protecting releases with retention only.** Anyone can still overwrite them.
> - **Expecting immutability to block new tags.** Only existing matching tags are protected.
> - **Adding a rule after a replication failed and expecting it to repair the tag.** Fix the content first.

## Your mission: Combine Two Retention Rules With Immutability

You can now write both kinds of rules, choose their selectors and read a dry run. The graded lab gives you a project with two repositories and asks you to keep two builds in one, everything in the other, and protect releases.

The lab runs in its own cluster, so first pause your playground. Nothing in it is lost:

```sh
astrona stop ats-101-playground-020-03
```

Then start the lab:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/section-020/module-03/labs/lab-01
```

The task is on the next page. Solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/module-03/labs/lab-01
```

When the lab is done, remove it and start your playground again:

```sh
astrona destroy ats-101-lab-020-03
astrona start ats-101-playground-020-03
```
