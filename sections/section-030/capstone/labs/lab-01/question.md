# Question

Solve this question on: `terminal`

**Time:** about 35 minutes · **Topic:** Identity integration with OIDC

## Scenario

Harbor was switched to OIDC with Keycloak last night. This morning, nobody can sign in. The few people who tested earlier say that even when sign-in worked on another system, their group access never showed up, and the platform team never got administrator rights. The person who set it up left these notes:

| Item | Intended value |
| --- | --- |
| Issuer | `http://keycloak.localtest.me:8180/realms/harbor` |
| Client | `harbor` / `harbor-client-secret` |
| Groups claim (from the Keycloak mapper) | `groups` |
| Developers of `inventory` | Keycloak group `inventory-devs` |
| Harbor administrators | Keycloak group `platform-admins` |

The faults are in Harbor's settings **and** in the Keycloak client. Run Harbor commands in the workstation pod. The Harbor administrator is `admin` (`Harbor12345`); the Keycloak administrator is `admin` (`admin`).

## Your task

1. Find every setting that differs from the intended values, in Harbor and in the Keycloak client `harbor`.
2. Fix them so that sign-in, group access and administrator rights all work.

## Constraints

- Keep Harbor in OIDC mode, and keep automatic onboarding with `preferred_username`.
- Do not create local Harbor users and do not add users to `inventory` one by one.
- Do not change the client secret.

## Done when

- Harbor's OIDC settings match the notes, and Harbor can reach the endpoint.
- The OIDC group `inventory-devs` is Developer of `inventory`.
- `alice` can sign in and push to `inventory` with her CLI secret, and `carol` cannot push there.
- `bob` is a Harbor administrator after he signs in.
