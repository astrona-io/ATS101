# Summary

Harbor builds one search for each sign-in from the base DN, the configured filter and the typed name. Only a user that the search finds as exactly one entry can reach the password check, which is a bind as the found DN. A filter combines tests in brackets with `&`, `|` and `!`, and a filter such as one that excludes an employment type keeps a whole class of users out. The scope sets the depth of the search: `0` for the base only, `1` for one level and `2` for the whole subtree. The `ping` call tests the connection and the bind, not the effect of the filter.

Groups give access when they are project members with a role. An LDAP group has the type `1` and is stored by its DN. Harbor can search the directory for groups, and it matches the DNs in the user's `memberOf` attribute at sign-in. Two groups can have different roles in one project, such as Developer and Guest. A typing error in the stored DN means no user ever matches.

A directory user becomes a Harbor user at the first sign-in or by an import. When a person leaves the directory, sign-in stops, and the Harbor record, the memberships and the robot accounts stay until an administrator removes them. When sign-in breaks, test the steps in order: connect, bind as the search DN, search, bind as the user, and read the groups. Run each step with `ldapsearch` before blaming Harbor. The key facts to remember are these:

- A user the search cannot find never reaches the password check.
- `ping` does not test the filter.
- Leavers need a manual clean-up in Harbor.
- Active Directory uses `sAMAccountName`, not `uid`.

<!-- astrona:playground:destroy -->
