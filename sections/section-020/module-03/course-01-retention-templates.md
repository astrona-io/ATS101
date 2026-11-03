# Retention Templates

A retention rule has to answer one question for every artifact: keep it or not. Harbor answers with a template. This part goes through the five templates, the parameter each one takes, and what the word "keep" means for each.

## The shape of a rule

Every rule in the REST API has the same fields: a `template`, a `params` object with the template's parameter, `tag_selectors` that choose tags, `scope_selectors` that choose repositories, an `action` that is always `retain`, and a `disabled` flag. The template decides which of the selected artifacts are kept. Read the policy of the project, if any, to see the shape:

<!-- astrona:playground:renew -->

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/catalog | jq .metadata'
```

At the start, `metadata` has no `retention_id`, because the project has no policy. Harbor adds `retention_id` after you create one.

## The five templates

- `latestPushedK` keeps the K artifacts that were pushed most recently. The parameter is `latestPushedK`, a number.
- `latestPulledK` keeps the K artifacts that were pulled most recently. The parameter is `latestPulledK`.
- `nDaysSinceLastPush` keeps the artifacts pushed within the last N days. The parameter is `nDaysSinceLastPush`.
- `nDaysSinceLastPull` keeps the artifacts pulled within the last N days. The parameter is `nDaysSinceLastPull`.
- `always` keeps every artifact that the selectors choose. It has no parameter.

A common mistake is to read "most recent" as "the K newest tags". The templates count artifacts, and the count is taken per repository. With K set to 2 and two repositories, Harbor keeps two artifacts in each repository, four in total.

## Pushed versus pulled

The two kinds of time answer different questions. Push time says how old the build is. Pull time says whether anyone still uses it. An artifact that was pushed a year ago and pulled yesterday is old by push time and fresh by pull time. Harbor records pull time when a client pulls the artifact, and an artifact that nobody has pulled has no pull time. Under `latestPulledK`, such an artifact is not among the recently pulled, so it is not kept by that rule.

Harbor can only record a pull if it sees the request. A pull that goes through a cache or another registry mirror does not reach Harbor and leaves no record.

## A first rule

Save this as `rule-latest-two.json` and replace `<PROJECT_ID>` with the project ID (`ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/catalog | jq .project_id'`):

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
    }
  ],
  "trigger": { "kind": "Schedule", "settings": { "cron": "" } },
  "scope": { "level": "project", "ref": <PROJECT_ID> }
}
```

Create it:

```sh
ws curl -s -u admin:Harbor12345 -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/retentions < rule-latest-two.json
```

The rule keeps the two newest artifacts among the `build-*` tags in each repository. It says nothing about `release-1.0`, so a real run would delete it. The next parts show how to avoid that.

## Changing a rule

A policy changes with `PUT /retentions/<id>` and a full body. The policy cannot be partly updated, so read it first, edit the JSON and send all of it. The `harbor` CLI has no retention commands in version 0.0.27, so this course uses the API.

You now know the five templates and what each keeps. The templates only work on the artifacts that the selectors choose, which is the subject of the next part.

## Common pitfalls

> [!WARNING]
> - **Reading K as a total for the project.** The count applies to each repository.
> - **Using `latestPulledK` for artifacts nobody pulls.** They have no pull time and are not kept by it.
> - **Forgetting the releases.** A rule that selects `build-*` says nothing about other tags, and a run deletes them.
> - **Sending part of a policy to PUT.** Send the whole body.
