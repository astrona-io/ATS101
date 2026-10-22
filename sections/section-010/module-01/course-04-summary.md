# Summary

A Harbor project is the unit of access control. Every repository lives in exactly one project, and the project's name is the first part of the repository path. A project is public or private. Anyone can pull from a public project, even without signing in; only members can see a private one. Nobody pushes to a project without being a member, so public is about reading only. Make a project public only when everyone who can reach Harbor may read everything in it.

Access to a private project comes from membership. A member is a user or a group, and each member has one role in that project. The five roles add rights in this order: Limited Guest and Guest pull, Developer also pushes, Maintainer also deletes artifacts, scans and manages immutability rules, and Project Admin also manages members and robot accounts. The REST API uses numbers for the roles: 1 Project Admin, 2 Developer, 3 Guest, 4 Maintainer, 5 Limited Guest. A system administrator stands above every project, and some settings, such as storage quotas, belong to the system administrator alone.

The `harbor` command-line tool creates users, projects and memberships, and the REST API returns the members in a stable JSON format for scripts and checks. The creator of a project becomes its Project Admin. When a person leaves a team, remove the membership instead of lowering the role. The key facts to remember are these:

- Private is the safe default; a public project gives read access to everyone.
- Give each member the smallest role that lets them work.
- A role belongs to one user in one project, and nowhere else.
- Prove access with a push and a pull as the user, not by reading the member list.

<!-- astrona:playground:destroy -->
