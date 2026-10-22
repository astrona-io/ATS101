# Question

Solve this question on: `terminal`

**Time:** about 25 minutes · **Topic:** Identity integration with LDAP

## Scenario

The company's directory is OpenLDAP, and Harbor must use it. The inventory developers are in the group `inventory-devs`, the platform team in `harbor-admins`. Harbor still checks passwords in its own database and has no users except `admin`.

| Setting | Value |
| --- | --- |
| LDAP URL | `ldap://openldap.ldap.svc.cluster.local:389` |
| Search DN and password | `cn=admin,dc=example,dc=org` / `admin-password` |
| Users | entries of class `inetOrgPerson` under `ou=people,dc=example,dc=org`, sign-in name in `uid` |
| Groups | entries of class `groupOfNames` under `ou=groups,dc=example,dc=org`, name in `cn` |
| Group membership | the user attribute `memberof` |

Run Harbor commands in the workstation pod. The Harbor administrator is `admin` with the password `Harbor12345`.

## Your task

1. Switch Harbor to LDAP authentication with the settings above, searching the whole subtree for users and groups. The directory runs without TLS in this lab, so do not verify a certificate.
2. Make every member of the LDAP group `cn=inventory-devs,ou=groups,dc=example,dc=org` a Developer of the project `inventory`.
3. Make every member of `cn=harbor-admins,ou=groups,dc=example,dc=org` a Harbor system administrator.

## Constraints

- Do not create local Harbor users and do not add LDAP users to `inventory` one by one.
- Do not change anything in the directory.

## Done when

- Harbor's authentication mode is LDAP with the settings above, and Harbor can bind to the directory.
- The LDAP group `inventory-devs` is Developer of `inventory`.
- `dave` (in `inventory-devs`) can push to `inventory` with his directory password, and `erin` (in no group) cannot.
- `frank` (in `harbor-admins`) is a Harbor administrator.
