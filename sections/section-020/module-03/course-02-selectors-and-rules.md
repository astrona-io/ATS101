# Selectors And Combining Rules

A template says how many artifacts to keep. A selector says among which artifacts. The selectors decide whether a rule is safe, because a pattern that is too wide or too narrow changes the result of the whole policy. This part writes selectors and then combines rules.

## Two selectors per rule

A rule has a repository selector and a tag selector. The repository selector is in `scope_selectors.repository`. Its `decoration` is `repoMatches` or `repoExcludes`. The tag selector is in `tag_selectors`. Its `decoration` is `matches` or `excludes`. Both have `kind: doublestar` and a `pattern`.

A repository must pass the repository selector, and then a tag in it must pass the tag selector. The template counts only the artifacts that pass both. Artifacts that do not pass are not looked at by this rule.

## Doublestar patterns

The pattern syntax is doublestar. A single `*` matches any characters within one path segment, so `build-*` matches `build-1` and `build-final`. The `**` pattern matches across segments, so `**` as a repository pattern matches `web` and also `team/web`. A comma-separated list in one pattern matches any of its items, for example `{build-*,test-*}` in the brace form of the syntax. Check a new pattern with a dry run, because a typed pattern that matches nothing keeps nothing.

Repository names in the selector are written without the project name. In the project `catalog`, the repository `catalog/web` is selected by `web`.

## Untagged artifacts

An artifact can exist without a tag, for example after its tag was moved to a newer artifact. The tag selector of a rule has an option for untagged artifacts, and the web portal shows it as a checkbox. When a rule includes untagged artifacts, the template counts them like tagged ones. Without that option, the rule does not look at them. Read the policy in the portal to see the option, because the field is stored in the selector's `extras` and its exact use is easy to get wrong.

## Combining rules with OR

A policy keeps an artifact if any rule keeps it. The `algorithm` of the policy is `or`. A project can have up to 15 rules. Rules never remove each other's keeps. Two rules that overlap are harmless, and a rule that keeps everything makes the others pointless in its scope.

Use this to build exceptions. The first rule keeps two builds everywhere. The second keeps everything in `api`:

<!-- astrona:playground:renew -->

```json
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
```

Save this as `rule-keep-api.json`. It is the second item of the `rules` list from the previous part. Put both rules in one policy file `retention-two-rules.json` and send it with `PUT /retentions/<RETENTION_ID>`:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/retentions/<RETENTION_ID> < retention-two-rules.json
```

Replace `<RETENTION_ID>` with the `retention_id` from the project metadata.

## Excluding instead of including

A selector can also exclude. A rule with the tag decoration `excludes` and the pattern `release-*` applies to every tag except releases. Write the rule that way when you want to say what to protect, and write it with `matches` when you want to say what to manage. Do not use a rule to protect a tag from deletion if you also need to forbid overwriting it. A rule decides only what a retention run keeps. The immutability rules in the last part forbid the change itself.

## Disabling a rule

A rule has a `disabled` flag. A disabled rule stays in the policy and keeps nothing. If you disable the only rule that kept your releases, the next run deletes them. Disable with care and read a dry run afterwards.

You now know how selectors narrow a rule and how rules combine. A policy is still only a description. The next part makes it run.

## Common pitfalls

> [!WARNING]
> - **Writing the project name in a repository pattern.** Use `web`, not `catalog/web`.
> - **Assuming a later rule overrides an earlier one.** The rules combine with OR.
> - **Expecting an exclude rule to protect the excluded tags.** It only stops this rule from looking at them.
> - **Not testing a new pattern.** A pattern that matches nothing keeps nothing.
