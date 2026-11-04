# Solution: Set A Complete Security Policy On A Project

Work the task yourself first. Running `astrona submit -c sections/section-010/module-03/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: the scan and pull-blocking keys, the signature key with the allowlist, and the visibility of the project.

## Step 1: Read the project

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/payments | jq "{metadata, cve_allowlist}"'
```

The metadata shows `public` as `"true"`. The metadata is a map of strings, so every value in your request is a string.

## Step 2: Set the policy in one request

The metadata and the allowlist are fields of the same project request. Save this as `policy.json`:

```json
{
  "metadata": {
    "auto_scan": "true",
    "prevent_vul": "true",
    "severity": "high",
    "enable_content_trust_cosign": "true",
    "reuse_sys_cve_allowlist": "false",
    "public": "false"
  },
  "cve_allowlist": {
    "items": [ { "cve_id": "CVE-2024-3094" } ]
  }
}
```

Send it:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects/payments < policy.json
```

## Step 3: Check the result

Read the project again:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/payments | jq "{metadata, cve_allowlist}"'
```

Check that the keys have the values in the task, and that `CVE-2024-3094` is in the allowlist. Then check the visibility. A request without credentials must not return `200`:

```sh
ws curl -s -o /dev/null -w '%{http_code}\n' https://harbor.localtest.me:8443/api/v2.0/projects/payments
```

Run `astrona submit` to grade the lab.
