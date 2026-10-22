# Sign In To Harbor With LDAP And Use LDAP Groups

The company's directory already knows every employee and every team. A new developer joins the team's group in the directory and expects Harbor access the same day; a leaver is disabled in the directory and must lose Harbor access at once. If Harbor keeps its own users, both expectations fail.

The **Lightweight Directory Access Protocol (LDAP)** is the protocol Harbor uses to search a directory and to check a password with a **bind**, a sign-in to the directory as a user. Every entry in the directory has a **distinguished name (DN)**, its full path, such as `uid=dave,ou=people,dc=example,dc=org`. Keep one sentence in mind: **Harbor finds the user under the base DN, checks the password with a bind, and reads the groups from the user's `memberOf` attribute.**

The module has two parts. **LDAP Settings And Testing The Connection** looks at the directory and tests Harbor's settings before anything is saved. **LDAP Users, Groups And Project Membership** switches Harbor to LDAP, makes an LDAP group a project member and a second group the administrators, and proves both with pushes. A graded lab follows the second part.

## Learning objectives

After this module you can:

- Read a user and the user's groups in an LDAP directory.
- Name the LDAP settings Harbor needs to find and check a user.
- Test LDAP settings with `harbor ldap ping` before saving them.
- Explain how an LDAP user is onboarded at the first sign-in.
- Configure the group settings, and explain what `memberOf` does.
- Make an LDAP group a member of a project, and set the LDAP admin group.

## Before you start

You need to know what a Harbor project, a member and a role are. Basic LDAP words help: an entry, an attribute, an object class. This module explains the ones Harbor uses.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** at `https://harbor.localtest.me:8443` and **OpenLDAP** in the namespace `ldap`, at `ldap://openldap.ldap.svc.cluster.local:389`. The `workstation` pod holds the `harbor` CLI, `oras`, `curl` and `jq`, and trusts Harbor's certificate. The playground holds:

| Object | Where | What it is |
| --- | --- | --- |
| `admin` | Harbor | The system administrator, lab-only password `Harbor12345`; the only Harbor user |
| `inventory` | Harbor | A private project with no members except `admin` |
| `cn=admin,dc=example,dc=org` | OpenLDAP | The directory administrator, lab-only password `admin-password`; Harbor uses it to search |
| `dave`, `erin`, `frank` | OpenLDAP, `ou=people` | Users with the lab-only passwords `DavePass1`, `ErinPass1`, `FrankPass1` |
| `inventory-devs`, `harbor-admins` | OpenLDAP, `ou=groups` | Groups: `dave` is in `inventory-devs`, `frank` in `harbor-admins`, `erin` in neither |

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
