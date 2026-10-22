# Solution: Repair An LDAP Integration

Work the task yourself first. Running `astrona submit -c sections/section-040/capstone/labs/lab-01` after a step tells you which checks pass, without telling you what is left.

The grader checks the same four things as the module lab: the settings and a bind, the group membership with the right DN, pushes as `dave` and `erin`, and `frank`'s administrator rights.

## Step 1: Read Harbor's LDAP settings

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq "with_entries(select(.key | startswith(\"ldap\") or . == \"auth_mode\")) | map_values(.value)"'
```

Compare each value with the directory:

- `ldap_base_dn` is `ou=users,dc=example,dc=org`. The users are under `ou=people`, so no user is ever found and every sign-in fails.
- `ldap_group_search_filter` is `(objectClass=posixGroup)`. The groups are `groupOfNames`, so Harbor finds no groups.
- `ldap_group_membership_attribute` is `isMemberOf`. The directory fills `memberof`, so no user has any group.

## Step 2: Read the project membership

```sh
ws sh -c 'curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members | jq ".[] | {id, entity_name, entity_type, role_id}"'
ws sh -c 'curl -s -u admin:Harbor12345 "https://harbor.localtest.me:8443/api/v2.0/usergroups" | jq ".[] | {id, group_name, ldap_group_dn}"'
```

The group member of `inventory` is `inventory-dev`, with the DN `cn=inventory-dev,ou=groups,dc=example,dc=org`. The real group is `inventory-devs`, with an `s`. Check it in the directory:

```sh
kubectl -n ldap exec deploy/openldap -- ldapsearch -x -H ldap://localhost -D cn=admin,dc=example,dc=org -w admin-password -b ou=groups,dc=example,dc=org '(objectClass=groupOfNames)' cn
```

The directory has `inventory-devs` and `harbor-admins`, and no `inventory-dev`.

## Step 3: Fix the settings

Save the corrected values as `harbor-ldap-fix.json`. A `PUT` with only these keys leaves the others alone:

```json
{
  "ldap_base_dn": "ou=people,dc=example,dc=org",
  "ldap_group_search_filter": "(objectClass=groupOfNames)",
  "ldap_group_membership_attribute": "memberof"
}
```

Apply it and test:

```sh
ws curl -s -u admin:Harbor12345 -X PUT -H 'Content-Type: application/json' --data-binary @- https://harbor.localtest.me:8443/api/v2.0/configurations < harbor-ldap-fix.json
ws curl -s -o /dev/null -w '%{http_code}\n' -u admin:Harbor12345 -X POST -H 'Content-Type: application/json' -d '{}' https://harbor.localtest.me:8443/api/v2.0/ldap/ping
```

## Step 4: Replace the group member

Remove the member with the wrong DN, using its `id` from step 2, and add the right group:

```sh
ws curl -s -u admin:Harbor12345 -X DELETE https://harbor.localtest.me:8443/api/v2.0/projects/inventory/members/<MEMBER_ID>
echo Harbor12345 | ws harbor login https://harbor.localtest.me:8443 --username admin --password-stdin
ws harbor project member create inventory --groupname inventory-devs --grouptype 1 --ldapdn cn=inventory-devs,ou=groups,dc=example,dc=org --role Developer
```

## Step 5: Prove it and submit

Push as `dave` and `erin` and check `frank`, as in the module lab: `dave`'s push succeeds, `erin`'s is refused, and `frank` has `admin_role_in_auth` `true`. Then submit:

```sh
astrona submit -c sections/section-040/capstone/labs/lab-01
```

## Why the obvious shortcuts are wrong

| Shortcut | What happens |
| --- | --- |
| Rename the group in the directory to `inventory-dev` | The task forbids directory changes, and every other system uses `inventory-devs` |
| Set the base DN to `dc=example,dc=org` | Sign-in works, but Harbor searches groups as users too |
| Add `dave` by name to `inventory` | The broken group settings stay broken for everyone else |
| Switch back to database authentication | Harbor refuses once LDAP users exist, and it is not the task |
