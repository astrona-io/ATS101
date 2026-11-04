# Tune LDAP Search, Groups And User Lifecycle

A Harbor that signs people in through a directory works only as well as its search settings. A filter that is too wide lets contractors and service accounts in. A filter that is too narrow locks out employees. Groups that do not match the project members give the wrong access, and users who left the company can still have a Harbor record. The person who runs Harbor must be able to tune each of these.

A **Lightweight Directory Access Protocol (LDAP)** directory is a tree of entries, and an **LDAP filter** is a condition in brackets that selects entries, such as `(uid=dave)`. Keep one sentence in mind for the whole module: **Harbor builds one search from the base DN, your filter and the name typed at sign-in, and every user it can find that way may sign in.**

The module has four parts. **Choosing The User Search And Filter** narrows who may sign in. **Group Roles In Projects** gives LDAP groups different roles in one project. **Importing Users And Offboarding** covers the Harbor record of a directory user. **Troubleshooting LDAP Sign-In** gives a method for finding the failing step. A graded lab follows the second part.

## Learning objectives

After this module you can:

- Combine filters with `&` and `!` and test them with `ldapsearch`.
- Explain the three search scopes and choose one.
- Change Harbor's user filter so that a class of users cannot sign in.
- Search LDAP groups through Harbor and make two groups members of a project with different roles.
- Import an LDAP user before the first sign-in.
- Explain what Harbor keeps when a user leaves the directory, and remove the record.
- Find the failing step of a broken LDAP sign-in.

## Before you start

You need to know how Harbor connects to a directory, what the base DN, the UID attribute and the search DN are, and what the five project roles allow. This module starts with Harbor already in LDAP mode.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** at `https://harbor.localtest.me:8443` and **OpenLDAP** in the namespace `ldap`, with the base DN `dc=example,dc=org`. The `workstation` pod holds the `harbor` CLI, `oras`, `curl` and `jq`, and trusts Harbor's certificate. The playground holds:

| Object | Where | What it is |
| --- | --- | --- |
| `admin` | Harbor | The system administrator, lab-only password `Harbor12345` |
| `inventory` | Harbor | A private project with one artifact |
| `dave`, `erin`, `frank`, `gina`, `hank` | OpenLDAP | Users with the lab-only passwords `DavePass1`, `ErinPass1`, `FrankPass1`, `GinaPass1`, `HankPass1`; `hank` has the attribute `employeeType` set to `contractor` |
| `inventory-devs`, `inventory-readers`, `harbor-admins` | OpenLDAP | Groups; `dave` is in the first, `gina` in the second, `frank` in the third |

The directory administrator is `cn=admin,dc=example,dc=org` with the lab-only password `admin-password`. Harbor is in LDAP mode and searches all users of class `inetOrgPerson`.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
