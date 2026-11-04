# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** OIDC groups and roles

## Scenario

Harbor signs users in through Keycloak. The reports team needs access to the private project `reports`. The report writers must be able to push and pull. The report readers must be able to pull only. The group `platform-admins` should run Harbor, so its members must become Harbor administrators.

Run every Harbor command in the workstation pod. The built-in system administrator is `admin` with the password `Harbor12345`. Keycloak has the realm `harbor`. The users `alice` (in `report-writers`), `carol` (in `report-readers`) and `bob` (in `platform-admins`) have the passwords `AlicePass1`, `CarolPass1` and `BobPass1`.

## Your task

1. Make the OIDC group `report-writers` a member of the project `reports` with the role Developer.
2. Make the OIDC group `report-readers` a member of the project `reports` with the role Guest.
3. Make members of the OIDC group `platform-admins` Harbor administrators.

## Constraints

- Do not change the `admin` password.
- Do not change the Keycloak realm, users or groups.
- Do not turn off automatic onboarding or change the groups claim.

## Done when

- The groups `report-writers` and `report-readers` are members of `reports` with the roles Developer and Guest.
- The OIDC setting `oidc_admin_group` is `platform-admins`, and `bob` is a Harbor administrator after he signs in.
- `alice` can push to `reports` with her CLI secret, `carol` can pull but cannot push.
