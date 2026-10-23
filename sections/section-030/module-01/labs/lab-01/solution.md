# Solution: Connect Harbor To Keycloak And Map A Group

Work the task yourself first. Running `astrona submit -c sections/section-030/module-01/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks four things: the OIDC settings and a successful endpoint test, the group membership, a real sign-in through Keycloak for `alice` and `carol` followed by a push with each CLI secret, and administrator rights for `bob` after he signs in. It signs users in with `curl`, following the same redirects a browser does.

## Step 1: Check that the mode can change

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq .auth_mode'
```

`value` is `db_auth` and `editable` is `true`, because Harbor has no users except `admin`.

## Step 2: Test the endpoint

```sh
ws curl -s -o /dev/null -w '%{http_code}\n' -u admin:Harbor12345 -H 'Content-Type: application/json' -d '{"url":"http://keycloak.localtest.me:8180/realms/harbor","verify_cert":false}' https://harbor.localtest.me:8443/api/v2.0/system/oidc/ping
```

`200` means Harbor's `core` reaches Keycloak's discovery document.

## Step 3: Switch Harbor to OIDC

Save this as `harbor-oidc.json`. It includes the admin group, so one call sets everything:

```json
{
  "auth_mode": "oidc_auth",
  "oidc_name": "keycloak",
  "oidc_endpoint": "http://keycloak.localtest.me:8180/realms/harbor",
  "oidc_client_id": "harbor",
  "oidc_client_secret": "harbor-client-secret",
  "oidc_scope": "openid,profile,email",
  "oidc_groups_claim": "groups",
  "oidc_admin_group": "platform-admins",
  "oidc_verify_cert": false,
  "oidc_auto_onboard": true,
  "oidc_user_claim": "preferred_username"
}
```

Apply it and read it back:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < harbor-oidc.json
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq "with_entries(select(.key | startswith(\"oidc\") or . == \"auth_mode\")) | map_values(.value)"'
```

The output lists every OIDC setting with its value. The client secret is not shown back.

## Step 4: Make the group a Developer of inventory

OIDC groups have the group type `3`:

```sh
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
ws curl -s -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' -d '{"role_id":2,"member_group":{"group_name":"inventory-devs","group_type":3}}' https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members | jq -r ".[] | [.entity_name, .entity_type, .role_id] | @tsv"'
```

The list shows `inventory-devs g 2`.

## Step 5: Prove it with a sign-in

Start the two port-forwards in two extra terminals, `kubectl -n harbor port-forward svc/harbor 8443:8443` and `kubectl -n keycloak port-forward svc/keycloak 8180:8180`, and open `https://harbor.localtest.me:8443`. Sign in with the `keycloak` button as `alice` (`AlicePass1`), open **User Profile** and copy the CLI secret. Then push with it:

```sh
echo '<CLI_SECRET>' | ws oras login --registry-config /tmp/alice.json -u alice --password-stdin harbor.localtest.me:8443
ws sh -c 'cd /tmp && date > note.txt && oras push --registry-config /tmp/alice.json harbor.localtest.me:8443/inventory/app:alice note.txt'
```

The push succeeds. Sign in as `bob` in a private browser window; the top menu shows the administration pages, because he is in `platform-admins`.

## Step 6: Submit

```sh
astrona submit -c sections/section-030/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Create local users `alice` and `bob` | Harbor can no longer switch to OIDC, and the users are not tied to Keycloak |
| Add `alice` to `inventory` by name | It works for her only; the next developer in `inventory-devs` gets nothing |
| Leave automatic onboarding off | Each user must type a name at the first sign-in; the grader's sign-in stops there |
| Make `inventory` public so everyone can pull | Anyone can read it, and nobody new can push |
