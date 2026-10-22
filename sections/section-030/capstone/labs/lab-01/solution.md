# Solution: Repair A Broken OIDC Sign-In

Work the task yourself first. Running `astrona submit -c sections/section-030/capstone/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks the same four things as the module lab: the settings and the endpoint test, the group membership, a real sign-in for `alice` and `carol` with a push each, and administrator rights for `bob`.

## Step 1: Read Harbor's settings

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq "with_entries(select(.key | startswith(\"oidc\") or . == \"auth_mode\")) | map_values(.value)"'
```

Compare with the notes. Three values differ:

- `oidc_endpoint` ends in `/realms/master`, not `/realms/harbor`. The client `harbor` does not exist in the realm `master`, so Keycloak refuses every sign-in.
- `oidc_groups_claim` is `group`, but the mapper writes `groups`. Harbor would find no groups at all.
- `oidc_admin_group` is `admins`, a group that does not exist. Nobody becomes administrator.

## Step 2: Read the Keycloak client

```sh
kcadm() { kubectl -n keycloak exec -i deploy/keycloak -- /opt/keycloak/bin/kcadm.sh "$@" --config /tmp/kcadm.config; }
kcadm config credentials --server http://localhost:8080 --realm master --user admin --password admin
kcadm get clients -r harbor -q clientId=harbor --fields id,clientId,redirectUris
```

The redirect URI is `https://harbor.localtest.me/c/oidc/callback`, without the port `8443`. Harbor sends `https://harbor.localtest.me:8443/c/oidc/callback`, which Keycloak does not accept, so even with the right realm the sign-in would stop at an invalid redirect.

## Step 3: Fix the Keycloak client

Use the client `id` from the previous output in place of `<CLIENT_UUID>`:

```sh
kcadm update clients/<CLIENT_UUID> -r harbor -s 'redirectUris=["https://harbor.localtest.me:8443/c/oidc/callback"]'
```

## Step 4: Fix Harbor's settings

A `PUT` with only the keys you change leaves the others alone. Save this as `harbor-oidc-fix.json`:

```json
{
  "oidc_endpoint": "http://keycloak.localtest.me:8180/realms/harbor",
  "oidc_groups_claim": "groups",
  "oidc_admin_group": "platform-admins"
}
```

Apply it and test the endpoint:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < harbor-oidc-fix.json
ws curl -s -o /dev/null -w '%{http_code}\n' -u admin:Harbor12345 -H 'Content-Type: application/json' -d '{"url":"http://keycloak.localtest.me:8180/realms/harbor","verify_cert":false}' https://harbor.localtest.me:8443/api/v2.0/system/oidc/ping
```

The test returns `200`.

## Step 5: Check the group membership

```sh
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members | jq -r ".[] | [.entity_name, .entity_type, .role_id] | @tsv"'
```

`inventory-devs g 2` is already there and correct. It never worked only because the groups claim was wrong.

## Step 6: Prove it and submit

Sign in through the browser as `alice`, copy her CLI secret from **User Profile**, and push to `inventory` with `oras`, as in the module. Sign in as `bob` and check that he sees the administration pages. Then submit:

```sh
astrona submit -c sections/section-030/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Add a wildcard redirect URI such as `*` in Keycloak | Keycloak would send codes to any address, which lets an attacker steal them |
| Change the mapper's claim name to `group` instead of Harbor's setting | It works, but the notes and every other client expect `groups`; the grader checks Harbor's setting |
| Switch back to database authentication | Harbor refuses once OIDC users exist, and it is not the task |
| Add `alice` to `inventory` by name | It hides the broken groups claim for one user only |
