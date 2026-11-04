# Section 010: Projects And Membership

One Harbor usually serves many teams. Each team wants to push its own images, and no team should read or overwrite another team's work. Harbor solves this with **projects**: every repository lives in exactly one project, and a project decides who may see it and what each person may do there.

This section teaches the two settings that decide access. The first is whether a project is public or private. The second is the list of **members** and the **role** each member has. You create projects and add members with the `harbor` command-line tool, read them back through the REST API, and prove every setting by pushing and pulling as the user in question.

**Topic covered:** Projects and roles

## What you will learn

- What a Harbor project is, and what makes a project public or private.
- What an anonymous client can and cannot do in each kind of project.
- The five project roles, Limited Guest, Guest, Developer, Maintainer and Project Admin, and what each one may do.
- Why only a system administrator can change some settings, such as storage quotas.
- Creating projects and adding, changing and removing members with the `harbor` CLI.
- Reading members and roles through the REST API, where each role has a number.
- Proving a role with a real push, pull or delete as that user.

## The learning path

### 1. Isolate Teams With Projects And Roles

The module starts at its landing page, which also launches the playground. The playground holds Harbor with three local users, `alice`, `bob` and `carol`, and a private project `inventory`.

1. Projects, Public And Private
2. Member Roles And What Each One May Do
3. Adding Members With The harbor CLI, followed by the lab **Isolate Two Teams With Projects And Roles**
4. Summary

### 2. Manage Local Users And System Administrators

1. Local Users And Database Authentication
2. System Administrators And Project Roles
3. System Settings That Control Tenancy
4. Offboarding Users, followed by the lab **Restrict Project Creation And Delegate Administration**
5. Summary

### 3. Set Project Security Policies

The playground holds the project `payments` and the users `alice` and `bob`. You change the project metadata with the REST API.

1. Project Metadata And The Project API
2. Vulnerability Scanning And Pull Blocking
3. The CVE Allowlist
4. Content Trust With Cosign, followed by the lab **Scan, Block And Sign Images In A Project**
5. Summary

### 4. Automate Access With Robot Accounts

The playground holds the project `web`, the user `alice` and an old robot account named `legacy`.

1. Robot Accounts And Their Names
2. Permissions: Resources, Actions And Scope
3. Using A Robot Account In A Pipeline
4. Operating Robot Accounts, followed by the lab **Replace A Legacy Robot With A Limited One**
5. Summary

## Section capstone: Repair Project Access For Three Teams

The capstone is one graded scenario that combines the whole module. A colleague set up two team projects in a hurry. One project is public, one user is Project Admin of a project he should not see at all, an auditor can push, and the person who cleans up old artifacts cannot delete anything. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/section-010/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-101-capstone-010
```
