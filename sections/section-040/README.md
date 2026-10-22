# Section 040: Identity Integration With LDAP

Many companies keep their users and groups in an LDAP directory, often Microsoft Active Directory. Harbor can check passwords against that directory and read the user's groups from it, so the directory decides who may sign in and which groups give access. Unlike OpenID Connect, LDAP needs no browser: `oras` and `docker` sign in with the user's own directory password.

This section connects Harbor to an OpenLDAP directory in the same cluster. You learn the settings Harbor needs to find a user and the user's groups, test them before you save, make an LDAP group a project member, and make another group Harbor administrators.

**Topic covered:** Identity integration with LDAP

## What you will learn

- The LDAP settings Harbor uses: URL, search DN and password, base DN, filter, UID and scope.
- Testing the connection with `harbor ldap ping` before you switch the mode.
- How Harbor finds a user, checks the password and onboards the user at the first sign-in.
- The group settings: group base DN, group filter, group name attribute and the `memberOf` attribute.
- LDAP groups as project members, and the LDAP admin group.

## The learning path

### 1. Sign In To Harbor With LDAP And Use LDAP Groups

The module starts at its landing page, which also launches the playground. The playground holds Harbor, still on database authentication with no users except `admin`, and an OpenLDAP directory with three users and two groups.

1. LDAP Settings And Testing The Connection
2. LDAP Users, Groups And Project Membership, followed by the lab **Give An LDAP Group Developer Access**
3. Summary

## Section capstone: Repair An LDAP Integration

The capstone is one graded scenario that combines the whole module. Harbor is already in LDAP mode, but nobody can sign in, groups are never found, and the developers' group membership points at a group that does not exist. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/section-040/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-040/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-101-capstone-040
```
