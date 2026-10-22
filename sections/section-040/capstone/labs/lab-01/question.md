# Question

Solve this question on: `terminal`

**Time:** about 35 minutes · **Topic:** Identity integration with LDAP

## Scenario

Harbor was switched to LDAP last week. Nobody can sign in, and an earlier test showed that even when sign-in works, no user is ever in a group. The developers of `inventory` are supposed to be the LDAP group `cn=inventory-devs,ou=groups,dc=example,dc=org`, and the platform team in `cn=harbor-admins,ou=groups,dc=example,dc=org` is supposed to administer Harbor.

The directory is correct: users are `inetOrgPerson` entries under `ou=people,dc=example,dc=org` with the sign-in name in `uid`; groups are `groupOfNames` entries under `ou=groups,dc=example,dc=org`; the directory fills each user's `memberof` attribute.

Run Harbor commands in the workstation pod. The Harbor administrator is `admin` (`Harbor12345`); you can search the directory as `cn=admin,dc=example,dc=org` (`admin-password`) from the OpenLDAP pod.

## Your task

1. Find every Harbor setting and membership that does not match the directory.
2. Fix them so LDAP users can sign in, `inventory-devs` members are Developers of `inventory`, and `harbor-admins` members are Harbor administrators.

## Constraints

- Keep Harbor in LDAP mode, and do not change the directory.
- Do not create local users and do not add LDAP users to `inventory` one by one.

## Done when

- Harbor's LDAP user and group settings match the directory, and Harbor can bind to it.
- The LDAP group `inventory-devs`, with its correct DN, is Developer of `inventory`.
- `dave` can push to `inventory` and `erin` cannot.
- `frank` is a Harbor administrator.
