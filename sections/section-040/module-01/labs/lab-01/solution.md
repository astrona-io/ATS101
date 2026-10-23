# Solution: Give An LDAP Group Developer Access

Work the task yourself first. Running `astrona submit -c sections/section-040/module-01/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks four things: the LDAP settings and a successful bind, the group membership, a push as `dave` that works and one as `erin` that is refused, and administrator rights for `frank`.

## Step 1: Test the user settings

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws harbor login https://harbor.localtest.me:8443 --username admin --password Harbor12345
ws harbor ldap ping --ldap-url ldap://openldap.ldap.svc.cluster.local:389 --ldap-search-dn cn=admin,dc=example,dc=org --ldap-password admin-password --ldap-base-dn ou=people,dc=example,dc=org --ldap-filter '(objectClass=inetOrgPerson)' --ldap-uid uid --ldap-scope 2
```

The ping reports a working connection.

## Step 2: Switch Harbor to LDAP

Save this as `harbor-ldap.json`. Scope `2` is the whole subtree:

```json
{
  "auth_mode": "ldap_auth",
  "ldap_url": "ldap://openldap.ldap.svc.cluster.local:389",
  "ldap_search_dn": "cn=admin,dc=example,dc=org",
  "ldap_search_password": "admin-password",
  "ldap_base_dn": "ou=people,dc=example,dc=org",
  "ldap_filter": "(objectClass=inetOrgPerson)",
  "ldap_uid": "uid",
  "ldap_scope": 2,
  "ldap_verify_cert": false,
  "ldap_group_base_dn": "ou=groups,dc=example,dc=org",
  "ldap_group_search_filter": "(objectClass=groupOfUniqueNames)",
  "ldap_group_attribute_name": "cn",
  "ldap_group_search_scope": 2,
  "ldap_group_membership_attribute": "memberof",
  "ldap_group_admin_dn": "cn=harbor-admins,ou=groups,dc=example,dc=org"
}
```

Apply it and test the saved settings:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < harbor-ldap.json
ws curl -s -o /dev/null -w '%{http_code}\n' -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' -d '{}' https://harbor.localtest.me:8443/api/v2.0/ldap/ping
```

The ping returns `200`.

## Step 3: Make the group a Developer

LDAP groups are type `1` and are identified by their DN:

```sh
ws curl -s -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' -d '{"role_id":2,"member_group":{"group_name":"inventory-devs","group_type":1,"ldap_group_dn":"cn=inventory-devs,ou=groups,dc=example,dc=org"}}' https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members | jq -r ".[] | [.entity_name, .entity_type, .role_id] | @tsv"'
```

The list shows `inventory-devs g 2`.

## Step 4: Prove it

```sh
echo DavePass1 | ws oras login --registry-config /tmp/dave.json -u dave --password-stdin harbor.localtest.me:8443
ws sh -c 'cd /tmp && date > note.txt && oras push --registry-config /tmp/dave.json harbor.localtest.me:8443/inventory/app:dave note.txt'
echo ErinPass1 | ws oras login --registry-config /tmp/erin.json -u erin --password-stdin harbor.localtest.me:8443
ws sh -c 'cd /tmp && oras push --registry-config /tmp/erin.json harbor.localtest.me:8443/inventory/app:erin note.txt'
ws sh -c 'curl -s -u frank:FrankPass1 https://harbor.localtest.me:8443/api/v2.0/users/current | jq "{username, admin_role_in_auth}"'
```

`dave`'s push succeeds, `erin`'s is refused, and `frank` has `admin_role_in_auth` `true`.

## Step 5: Submit

```sh
astrona submit -c sections/section-040/module-01/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Import `dave` and add him to `inventory` by name | The next developer in `inventory-devs` gets nothing |
| Set the base DN to `dc=example,dc=org` | It works here, but searches the whole directory, groups included; the grader checks the base DN from the task |
| Make `frank` an administrator by hand in Harbor | It does not follow the directory; removing him from `harbor-admins` would change nothing |
| Leave the group settings empty | Harbor finds no groups, and the group membership never applies |
