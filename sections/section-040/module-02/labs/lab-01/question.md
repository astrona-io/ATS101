# Question

Solve this question on: `terminal`

**Time:** about 20 minutes · **Topic:** LDAP search settings and group roles

## Scenario

Harbor signs users in through the company directory. The directory also holds contractors, and the security team does not want contractors to sign in to Harbor. Contractors are the entries with the attribute `employeeType` set to `contractor`. At the same time, the project `inventory` needs two groups: the developers push and pull, and the readers only pull.

Run every Harbor command in the workstation pod. The built-in system administrator is `admin` with the password `Harbor12345`. The directory users `dave` (in `inventory-devs`), `gina` (in `inventory-readers`), `erin` and `hank` (a contractor) have the passwords `DavePass1`, `GinaPass1`, `ErinPass1` and `HankPass1`.

## Your task

1. Change the Harbor LDAP user filter so that users with `employeeType` equal to `contractor` cannot sign in, and all other users of the class `inetOrgPerson` still can.
2. Make the LDAP group `inventory-devs` a member of the project `inventory` with the role Developer.
3. Make the LDAP group `inventory-readers` a member of the project `inventory` with the role Guest.

## Constraints

- Do not change the `admin` password.
- Do not change the directory.
- Do not change the base DN, the UID attribute or the admin group.

## Done when

- `hank` receives HTTP 401 when he signs in to the Harbor API, and `dave`, `erin` and `frank` receive HTTP 200.
- The groups `inventory-devs` and `inventory-readers` are members of `inventory` with the roles Developer and Guest, with their directory DNs.
- `dave` can push to `inventory`, `gina` can pull and cannot push.
