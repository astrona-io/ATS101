# Configuring Harbor For Keycloak

Harbor and Keycloak must agree on three things before a sign-in works: which client Harbor is, where Keycloak may send the browser back to, and which claims in the token carry the user name and the groups. This part reads the Keycloak side, writes the Harbor side, tests the connection, and signs a user in through the browser.

## The Keycloak client

In Keycloak, Harbor is a **client**: an application that asks Keycloak to sign users in. Harbor's client is **confidential**, which means it proves who it is with a **client secret** when it exchanges the code for tokens. Read the client's settings with `kcadm.sh`, Keycloak's administration command-line tool, which runs inside the Keycloak pod:

<!-- astrona:playground:renew -->

```sh
kcadm() { kubectl -n keycloak exec -i deploy/keycloak -- /opt/keycloak/bin/kcadm.sh "$@" --config /tmp/kcadm.config; }
kcadm config credentials --server http://localhost:8080 --realm master --user admin --password admin
kcadm get clients -r harbor -q clientId=harbor --fields clientId,publicClient,redirectUris
```

The output shows `publicClient` `false` and one redirect URI, `https://harbor.localtest.me:8443/c/oidc/callback`. The **redirect URI** is the only address Keycloak will send the browser back to with a code. Harbor builds it from its external URL plus `/c/oidc/callback`, so it must match Harbor's address exactly, including the port. A Keycloak mapper on this client also writes the user's group names into a claim called `groups`.

## The Harbor settings

Harbor needs these settings, all part of its system configuration:

| Setting | API key | Value here |
| --- | --- | --- |
| Authentication mode | `auth_mode` | `oidc_auth` |
| Provider name, shown on the sign-in button | `oidc_name` | `keycloak` |
| Provider endpoint, the issuer | `oidc_endpoint` | `http://keycloak.localtest.me:8180/realms/harbor` |
| Client ID and secret | `oidc_client_id`, `oidc_client_secret` | `harbor`, `harbor-client-secret` |
| Scope | `oidc_scope` | `openid,profile,email` (must include `openid`) |
| Groups claim | `oidc_groups_claim` | `groups` |
| Verify the provider's certificate | `oidc_verify_cert` | `false` here, because Keycloak runs without TLS in this lab |
| Automatic onboarding | `oidc_auto_onboard` | `true` |
| Username claim | `oidc_user_claim` | `preferred_username` |

**Automatic onboarding** means Harbor creates its own user record at the first sign-in and takes the user name from the claim named in **username claim**, here `preferred_username`. Without it, Harbor asks the user to type a user name the first time. The username claim must be in the ID token, or onboarding fails.

## Testing the endpoint before saving

Harbor can test an endpoint without saving anything. It fetches the discovery document from Harbor's own `core` component, so the test proves that Harbor, not only your browser, can reach Keycloak:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws curl -s -o /dev/null -w '%{http_code}\n' -u admin:Harbor12345 -H 'Content-Type: application/json' -d '{"url":"http://keycloak.localtest.me:8180/realms/harbor","verify_cert":false}' https://harbor.localtest.me:8443/api/v2.0/system/oidc/ping
```

The answer is `200`. A wrong realm or host gives an error code instead, and that is the cheapest place to find the mistake.

## Switching Harbor to OIDC

Save the settings as `harbor-oidc.json`:

```json
{
  "auth_mode": "oidc_auth",
  "oidc_name": "keycloak",
  "oidc_endpoint": "http://keycloak.localtest.me:8180/realms/harbor",
  "oidc_client_id": "harbor",
  "oidc_client_secret": "harbor-client-secret",
  "oidc_scope": "openid,profile,email",
  "oidc_groups_claim": "groups",
  "oidc_verify_cert": false,
  "oidc_auto_onboard": true,
  "oidc_user_claim": "preferred_username"
}
```

Apply it with a `PUT` to the configuration, then read the mode back:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < harbor-oidc.json
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq "{auth_mode: .auth_mode.value, endpoint: .oidc_endpoint.value}"'
```

The mode is now `oidc_auth`. The `admin` account still signs in with its password; it is the one account that never goes through OIDC.

## A first sign-in

Sign in as `carol` through a browser. Start both port-forwards in two extra terminals and leave them running:

```sh
kubectl -n harbor port-forward svc/harbor 8443:8443
kubectl -n keycloak port-forward svc/keycloak 8180:8180
```

Open `https://harbor.localtest.me:8443` and accept the lab certificate. The sign-in page now has a button for the provider `keycloak`. Click it: the browser goes to Keycloak's sign-in page for the realm `harbor`. Sign in as `carol` with `CarolPass1`, and the browser comes back to Harbor, signed in. Then check, as `admin`, that Harbor created the user:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/users" | jq -r ".[].username"'
```

The list now has `carol` next to `admin`. Harbor onboarded her at the callback, with the name from `preferred_username`. She has no project memberships, so she sees no private projects.

You now know which settings Harbor needs, how to test the endpoint, how to switch the mode, and what automatic onboarding does. The open question is how `carol`, or anyone else, gets access to projects without a local membership for each person, and how a tool like `oras` signs in at all.

## Common pitfalls

> [!WARNING]
> - **A redirect URI without the port.** Keycloak refuses to send the browser to any address that is not registered exactly, and the sign-in stops with an invalid redirect error.
> - **Forgetting `openid` in the scope.** Without it, the provider returns no ID token.
> - **Automatic onboarding with a claim that is not in the token.** Onboarding fails for every user.
> - **Testing with the browser only.** The `ping` call proves that Harbor's `core` reaches the provider, which the browser cannot prove.
