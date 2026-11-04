# Solution: Narrow The LDAP Filter And Give Two Groups Different Roles

Work the task yourself first. Running `astrona submit -c sections/section-040/module-02/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks three things: who can sign in, the two group roles, and what `dave` and `gina` can do.

## Step 1: Test the filter in the directory

Test the new filter against the directory before you give it to Harbor. Harbor adds the UID test with `&`, so test the filter together with a UID:

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
kubectl -n ldap exec deploy/openldap -- ldapsearch -x -H ldap://localhost -D cn=admin,dc=example,dc=org -w admin-password -b ou=people,dc=example,dc=org '(&(&(objectClass=inetOrgPerson)(!(employeeType=contractor)))(uid=hank))' uid
kubectl -n ldap exec deploy/openldap -- ldapsearch -x -H ldap://localhost -D cn=admin,dc=example,dc=org -w admin-password -b ou=people,dc=example,dc=org '(&(&(objectClass=inetOrgPerson)(!(employeeType=contractor)))(uid=dave))' uid
```

The search for `hank` returns no entry, and the search for `dave` returns one.

## Step 2: Change the filter in Harbor

Save this as `ldap-filter.json`:

```json
{ "ldap_filter": "(&(objectClass=inetOrgPerson)(!(employeeType=contractor)))" }
```

Send it, then sign in as `hank` and as `dave`:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < ldap-filter.json
ws curl -s -o /dev/null -w '%{http_code}\n' -u hank:HankPass1 https://harbor.localtest.me:8443/api/v2.0/users/current
ws curl -s -o /dev/null -w '%{http_code}\n' -u dave:DavePass1 https://harbor.localtest.me:8443/api/v2.0/users/current
```

The answer for `hank` is `401` and for `dave` it is `200`.

## Step 3: Add the two groups

An LDAP group has the group type `1` and is stored with its DN. Search for the groups first to copy the DNs:

```sh
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/ldap/groups/search?groupname=inventory" | jq -r ".[] | [.ldap_group_name, .ldap_group_dn] | @tsv"'
```

Save this as `member-devs.json`:

```json
{
  "role_id": 2,
  "member_group": {
    "group_name": "inventory-devs",
    "group_type": 1,
    "ldap_group_dn": "cn=inventory-devs,ou=groups,dc=example,dc=org"
  }
}
```

Save this as `member-readers.json`:

```json
{
  "role_id": 3,
  "member_group": {
    "group_name": "inventory-readers",
    "group_type": 1,
    "ldap_group_dn": "cn=inventory-readers,ou=groups,dc=example,dc=org"
  }
}
```

Send both and read the members back:

```sh
ws curl -s -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members < member-devs.json
ws curl -s -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members < member-readers.json
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members | jq -r ".[] | [.entity_name, .entity_type, .role_id] | @tsv"'
```

## Step 4: Prove the roles

```sh
echo DavePass1 | ws oras login --registry-config /tmp/dave.json -u dave --password-stdin harbor.localtest.me:8443
echo GinaPass1 | ws oras login --registry-config /tmp/gina.json -u gina --password-stdin harbor.localtest.me:8443
ws sh -c 'cd /tmp && date > note.txt && oras push --registry-config /tmp/dave.json harbor.localtest.me:8443/inventory/app:dave note.txt'
ws sh -c 'cd /tmp && oras push --registry-config /tmp/gina.json harbor.localtest.me:8443/inventory/app:gina note.txt'
ws sh -c 'cd /tmp && oras pull --registry-config /tmp/gina.json harbor.localtest.me:8443/inventory/app:dave'
```

The push by `dave` succeeds, the push by `gina` is refused, and the pull by `gina` succeeds. Run `astrona submit` to grade the lab.
