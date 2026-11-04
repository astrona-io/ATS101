# Overview: Tune LDAP Search, Groups And User Lifecycle (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor, OpenLDAP and the workstation, and switches Harbor to LDAP sign-in. There is no task, no `astrona submit` and no pass or fail. Explore, change things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** at `https://harbor.localtest.me:8443`, already in LDAP mode. The built-in `admin` (`Harbor12345`) still signs in with its database password. The private project `inventory` holds one artifact and has no members.
- **OpenLDAP** in the namespace `ldap`, base DN `dc=example,dc=org`, directory administrator `cn=admin,dc=example,dc=org` with the lab-only password `admin-password`. It holds:
  - the users `dave` (`DavePass1`), `erin` (`ErinPass1`), `frank` (`FrankPass1`), `gina` (`GinaPass1`) and `hank` (`HankPass1`) below `ou=people`; `hank` has `employeeType` set to `contractor`;
  - the groups `inventory-devs` (`dave`), `inventory-readers` (`gina`) and `harbor-admins` (`frank`) below `ou=groups`.
- Harbor's LDAP settings: the user base DN is `ou=people,dc=example,dc=org`, the filter is `(objectClass=inetOrgPerson)`, the UID attribute is `uid`, the scope is `2`, the group base DN is `ou=groups,dc=example,dc=org`, the membership attribute is `memberof`, and the admin group is `cn=harbor-admins,ou=groups,dc=example,dc=org`.
- The **workstation** pod with the `harbor` CLI v0.0.27, `oras`, `curl` and `jq`, trusting Harbor's certificate.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation and `ldap` runs a command in the directory pod.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ldap() { kubectl -n ldap exec -i deploy/openldap -- "$@"; }
ldap ldapsearch -x -H ldap://localhost -D cn=admin,dc=example,dc=org -w admin-password -b ou=people,dc=example,dc=org '(uid=hank)' uid employeeType
```

## Practice tasks

- Search the directory with filters that use `&`, `|` and `!`, and compare the results.
- Change `ldap_filter` so that contractors cannot sign in, and prove it with `curl -u hank:HankPass1`.
- Add `inventory-devs` and `inventory-readers` to `inventory` with different roles, and push and pull as `dave` and `gina`.
- Import `erin` before she signs in, then delete her Harbor record.
- Break one setting, such as the base DN, and follow the troubleshooting method until you find it.
