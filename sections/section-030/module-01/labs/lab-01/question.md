# Question

Solve this question on: `terminal`

**Time:** about 25 minutes · **Topic:** Identity integration with OIDC

## Scenario

The company signs everyone in through Keycloak, and Harbor must follow. Keycloak is ready: the realm `harbor` has the confidential client `harbor` with the secret `harbor-client-secret` and a mapper that puts group names into the claim `groups`. The developers of the inventory service are in the Keycloak group `inventory-devs`; the platform team is in `platform-admins`. Harbor still checks passwords in its own database and has no users except `admin`.

| Setting | Value |
| --- | --- |
| OIDC provider endpoint (issuer) | `http://keycloak.localtest.me:8180/realms/harbor` |
| Client ID and secret | `harbor` / `harbor-client-secret` |
| Groups claim | `groups` |

Run Harbor commands in the workstation pod. The Harbor administrator is `admin` with the password `Harbor12345`; the Keycloak administrator is `admin` with the password `admin`.

## Your task

1. Switch Harbor to OIDC authentication with Keycloak, using the settings above, the provider name `keycloak` and the scope `openid,profile,email`. New users must be created automatically at their first sign-in, with the Keycloak user name (`preferred_username`) as their Harbor name.
2. Make every member of the Keycloak group `inventory-devs` a Developer of the project `inventory`.
3. Make every member of the Keycloak group `platform-admins` a Harbor system administrator.

## Constraints

- Do not create local Harbor users, and do not add OIDC users to `inventory` one by one.
- Keycloak uses plain HTTP in this lab; do not try to turn TLS on.
- Do not change anything in Keycloak.

## Done when

- Harbor's authentication mode is OIDC with the settings above, automatic onboarding with `preferred_username`, and the admin group `platform-admins`, and Harbor can reach the endpoint.
- The OIDC group `inventory-devs` is Developer of `inventory`.
- `alice` (in `inventory-devs`) can sign in and push to `inventory` with her CLI secret, and `carol` (in no group) cannot push there.
- `bob` (in `platform-admins`) is a Harbor administrator after he signs in.
