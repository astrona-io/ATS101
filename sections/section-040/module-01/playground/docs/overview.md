# Overview: Sign In To Harbor With LDAP And Use LDAP Groups (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor, an OpenLDAP directory and the workstation, and then waits. There is no task, no `astrona submit` and no pass or fail. Explore, change things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** at `https://harbor.localtest.me:8443`, still on database authentication. Its only user is `admin` with the lab-only password `Harbor12345`. The private project `inventory` exists.
- **OpenLDAP** in the namespace `ldap`, at `ldap://openldap.ldap.svc.cluster.local:389`, base DN `dc=example,dc=org`, administrator `cn=admin,dc=example,dc=org` with the lab-only password `admin-password`:
  - users under `ou=people`: `dave` (`DavePass1`), `erin` (`ErinPass1`) and `frank` (`FrankPass1`);
  - groups under `ou=groups`: `inventory-devs` with `dave`, and `harbor-admins` with `frank`.
- The **workstation** pod with the `harbor` CLI v0.0.27, `oras`, `curl` and `jq`, trusting Harbor's certificate.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation, `ldap_find` searches the directory as its administrator, and `harbor_setting` prints one value of Harbor's configuration.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ldap_find() {
  kubectl -n ldap exec deploy/openldap -- ldapsearch -x -H ldap://localhost -D cn=admin,dc=example,dc=org -w admin-password -b dc=example,dc=org "$@"
}
harbor_setting() {
  ws sh -c "curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq -r '.$1.value'"
}
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
```

Use them like this: `ldap_find '(uid=frank)' memberOf`, `harbor_setting ldap_base_dn`.

## Practice tasks

- Run `harbor ldap ping` with a wrong base DN, a wrong UID attribute and a wrong password in turn, and note which mistakes the ping finds and which it does not.
- Switch Harbor to LDAP, then sign in as `erin` with `curl -u erin:ErinPass1 .../api/v2.0/users/current` and see her user record appear in Harbor.
- Import `frank` with `ws harbor ldap import frank` before he ever signs in, and compare his record with `erin`'s.
- Map `inventory-devs` with a wrong DN, push as `dave`, then correct the DN and push again.
- Set `ldap_group_membership_attribute` to `isMemberOf` and check whether `frank` is still an administrator.
