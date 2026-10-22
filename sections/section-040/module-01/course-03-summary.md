# Summary

LDAP lets Harbor check passwords against a directory and read users' groups from it, without a browser: registry clients sign in with the user's directory password. Every directory entry has a distinguished name, its full path, and a search filter in brackets selects entries.

Harbor finds a user in steps. It connects to the LDAP URL, binds as the search DN with the search password, and searches below the base DN with the filter and the UID attribute, to the depth the scope sets. When it finds the entry, it binds as that user with the typed password, so only the directory checks the password. A wrong URL, search DN, base DN, filter or UID stops every sign-in, which is why `harbor ldap ping` tests the settings before you save them. The authentication mode can change only while Harbor holds no users except `admin`. An LDAP user is onboarded at the first sign-in, or imported by the administrator.

Groups come from the user's `memberOf` attribute, which the directory fills on every member of a group. Harbor needs the group base DN, the group filter, the group name attribute and the membership attribute. An LDAP group, type `1`, identified by its DN, can be a project member with a role, and the group admin DN makes its members Harbor administrators. The key facts to remember are these:

- Harbor searches with the search DN, then binds as the user to check the password.
- Test LDAP settings before saving; one wrong value stops every sign-in.
- Groups come from `memberOf`, so the membership attribute and the group DN must match the directory exactly.
- LDAP users sign `oras` and `docker` in with their own directory password.

<!-- astrona:playground:destroy -->
