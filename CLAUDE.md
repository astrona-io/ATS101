# Writing style for this repo

All study text here (course pages, lab docs, READMEs, comments in YAML and
scripts) is for people learning a technical subject, often for a
certification exam. Many of them are not native English speakers and have no
university degree.

## Technical documentation in plain English

This is technical documentation. Say exactly what the system does, with the
real technical terms, in clear and simple English. Never hide a concept
behind a metaphor, a made-up name or a vague word: the reader must learn the
words they will meet in the product, the logs and the exam.

Strict guidelines:

1. Use the correct technical term every time (request, response, pod,
   namespace, Service, sidecar proxy, certificate, mTLS, JWT, listener). The
   first time a term appears in a file, define it in one plain sentence that
   says what it is and what it does. Spell out every acronym on first use.
2. No metaphors or analogies in explanations. Not "the communications
   officer", but "the sidecar proxy (Envoy)"; not "a signal", but "a
   request"; not "the planet", but "the namespace".
3. Simple sentences. Target a Flesch-Kincaid Grade Level of 8 or 9 for the
   prose around the terms. Keep sentences direct; split long sentences into
   two. No corporate buzzwords.
4. Use short paragraphs (max 3-4 sentences per paragraph).
5. Use the active voice ("istiod sends the configuration", not "the
   configuration is sent").

## How this applies to course material

- **Know which file you are in.** A module has a short landing page, a few
  deep-dive parts and a summary page. The landing page is a map: goals, what
  to know first, the order of the parts. The real teaching goes in the parts.
  The summary closes the module. A lab
  has a task, a step-by-step solution and a short intro. Keep each file to its
  job. Do not add "Prerequisite: ... Next: ..." navigation lines to pages;
  the landing page and the course outline already give the order.
- **Keep each part short.** One idea per part, about 5 to 8 minutes of
  reading and at most about 8 command blocks, so a learner can finish it with
  the playground in one sitting of about 15 minutes. Split at a natural seam
  where each half ends with something the learner has seen work. Never split
  only to hit a number. When you split, renumber the files, fix every "Part N"
  reference in the module and `astrona.yaml`.
- **Read like a book, not like a web page.** Each part reads as a chapter of
  a technical book. Open with a short paragraph on the problem it solves and
  why it matters. Link each paragraph to the next with a transition sentence.
  Close with a paragraph that sums up what the reader now knows and the
  question still open, before `## Common pitfalls` and the mission. Write
  explanations as prose; keep bullets for real lists (fields, ordered steps,
  options). Use `##` only when the topic changes and `###` only inside a long
  section, never for a single command. Weave hands-on steps into the text:
  one or two sentences on what to run and why, the command, the real output,
  then a sentence or two on what it shows.
- **The module ends with a summary.** The last page of every module is
  `course-0N-summary.md` with the title `# Summary`: a few short prose
  paragraphs on what the reader learned, organised by idea, optionally with
  one short list of key facts. It names no parts, modules, sections or
  chapters, and has no links, lab table, quiz or commands. Its last line is
  `<!-- astrona:playground:destroy -->` on its own line; the platform turns it
  into the step that removes the playground.
- **Every heading gets an intro.** A `##` section that has `###`
  subsections starts with one to three sentences that say what the section
  is about and why it matters, before the first `###`. Never put a `###`
  directly under a `##`.
- **Every module stands on its own.** Never refer to other sections or
  modules: no "see section 040", "as module 3 showed", "you met this in
  section 000", and no links to pages in another module. If the reader needs
  a fact from elsewhere, state the fact directly in one or two sentences.
  This also goes for parts of the same module: never write "Part 2 shows",
  "from Part 1" or "as in Part 3". Say the fact itself ("the commands below
  need the `scout` `DestinationRule` applied"). This includes the summary.
  The landing page does not have a "Where this fits" section.
- **Write words out in full.** Do not use informal short forms in prose:
  write "communications", "configuration", "repository", "administrator",
  "for example" and "that is", never "comms", "config", "repo", "admin",
  "e.g." or "i.e.". Names in code, commands and file paths stay as they are.
- **Exam terms stay.** The product's own names are what the reader must learn
  (for example a resource kind, a field, a command). Use them as they are and
  define each one in plain technical words the first time it appears in a
  file. Spell out acronyms on first use, with a short plain meaning.
- **The space theme is only for examples.** Space appears in two places and
  nowhere else: the names of the example workloads (the Starfleet: `bridge`,
  `scout`, `shuttle`, `probe`, the `starfleet` and `outpost` namespaces) and
  the short scenario that opens a lab task or a practice exercise (for
  example "the `drifter` in `outpost` must keep reaching the probe"). The
  explanation around an example is plain technical text: write "the
  `shuttle` pod sends a request to the `probe` Service", never "the shuttle
  sends a signal to the probe ship". Do not address the reader as an
  astronaut, and do not use space metaphors (communications officer, mission
  control, badge, airlock, guest list, star chart) for Istio or Kubernetes
  concepts. Titles of pages and labs name the technical task ("Require mTLS
  With PeerAuthentication"), not a space story.
- **Show one real example before the rule.** Start with a concrete case the
  reader can run, then give the general rule.
- **Say which part does the work.** Readers often mix up the parts of a system
  that sit close together. Whenever something happens, say which component
  did it.
- **Never change code to fit the style.** Commands, configuration files, field
  names, resource names, log lines and command output stay exactly as they
  are. They were run and checked on a real system. Never make up command
  output. If you shorten it, say that you did.
- **Prose only.** The grade-level and sentence rules apply to explanations.
  They do not apply to code blocks, tables of field names or reference lists
  (those may stay short and dense).
- **Keep the page furniture the same.** Hands-on steps are part of the prose
  (see "Read like a book"), not boxes or headings of their own. A `> [!TIP]` box is
  only for a real tip: advice the reader can reuse beyond this one step (a
  habit, a shortcut, how to spot a problem, an exam habit). Everything else
  is a normal sentence: notes about the current step ("if the log line is
  old, run it again"), background facts, optional extra steps, and plain
  information. Never a command snippet, never two in a row, and most pages
  need zero or one tip. Each part ends with a
  `## Common pitfalls` `> [!WARNING]` block for that part only. Use a Mermaid
  diagram for a flow, an order or a state change, keep it under about 12
  boxes, and follow it with one sentence that says what it shows.
- **Labs come right after the part they practise.** Do not collect all
  graded labs at the end of a module. In `astrona.yaml`, put each lab (its
  `question.md` reading and the `lab` entry) right after the reading part it
  tests. If a part teaches a gradeable skill and no lab covers it, create a
  new lab. That part then ends with a `## Your mission: <lab title>` section:
  one sentence on what the reader can now do, one on what the mission asks,
  then pause the playground (`astrona stop <playground name>`), the
  `astrona run` and `astrona submit` commands, and finally
  `astrona destroy <lab name>` plus `astrona start <playground name>`.
- **Renew the playground before hands-on work.** Every reading part that
  runs commands has `<!-- astrona:playground:renew -->` exactly once, on its
  own line, right before the first hands-on step (the first "Save this as"
  or the first command block), so the playground timer is reset before the
  learner needs the playground. Not on landing pages (they carry
  `<!-- astrona:playground -->`), summary pages (they carry
  `<!-- astrona:playground:destroy -->`) or pages without commands.
- **Mermaid without HTML.** The platform renders Mermaid with HTML labels
  switched off, so `<br/>` and any other HTML tag break the drawing. Rules:
  - One line per box, no `<br/>`, no HTML. Keep the box to the thing's name
    (`"scout-v2"`, `"istiod"`, `"Service: scout"`).
  - Put the logic on the arrows: `E -->|"version: v2"| P2`,
    `I -->|"CDS"| C`, `A -->|"end-user: jason"| B`. Keep edge labels short.
  - Quote every label. Prefer `flowchart TB`; use `LR` only for a short chain.
  - Sequence diagrams: short participant aliases (`participant S as shuttle`)
    and short message text.
  - Anything longer (cluster names, full hostnames) goes in the sentence under
    the diagram.
- **Every course starts with an Introduction.** It lives in `sections/intro/`
  and is the first entry in `astrona.yaml` (`id: module-intro`, title
  "Introduction"). It has exactly these four pages, in this order:
  - `README.md`, `# Introduction`: what the introduction covers and its three
    pages, named in prose (no links), ending with the topic the course starts
    with.
  - `course-01-welcome.md`, `# Welcome To The Course`: who the course is for,
    the exam domain and what the reader can do at the end, the words the
    course uses, the example app, how the course is laid out and how to read
    a page.
  - `course-02-get-your-machine-ready.md`, `# Get Your Machine Ready`: the
    tools to install, the `astrona` commands used every day, and what to do
    when a start goes wrong.
  - `course-03-how-this-course-is-made.md`, `# How This Course Is Made`: how
    content is written and checked, the maintainers, how to report a mistake,
    and the license.
  The Introduction teaches no product content and has no playground, labs or
  summary. Its only links are the repository's contributors page, issues
  page and license.
- **No links to other course files.** A course page (every reading listed in
  `astrona.yaml`, the playground guide `docs/overview.md`, and a lab's
  `question.md` and `solution.md`) never links to or points the reader at
  another page or file of the repository: no links to parts, summaries,
  labs, `question.md`, other modules, sections or the Introduction, and no
  "see `practice.md`" or "open `config.yaml`". The platform shows the pages in
  the order of `astrona.yaml`, so a link only adds a second, often wrong,
  path. Name a thing in plain words when the reader needs it ("the task is on
  the next page"), and state a fact on the page itself instead of sending the
  reader somewhere else. Repository files for authors (the root `README.md`,
  a lab's or playground's `README.md`) may link.
- **No links to outside sources.** Course pages, labs and playground docs do
  not link to or point at outside websites (the one exception is the
  `resources` field of a lab entry in `astrona.yaml`) (official docs, GitHub, blogs,
  RFCs), and they have no "Reference" or "Official docs" lists. Everything the
  reader needs is explained on the page itself. Not affected: addresses the
  reader actually uses in a command or browser (`http://127.0.0.1:9080`,
  `curl https://httpbin.org`), and the Introduction's contributors and
  "report a mistake" links.
- **Configuration goes to a file first.** Whenever the reader should apply
  YAML (course parts, playground docs, labs), use three separate steps:
  1. "Save this as `virtualservice-scout.yaml`:" followed by a plain
     ` ```yaml ` block with only the YAML. No `cat > file <<'EOF'`, no
     `kubectl apply -f - <<EOF`, no shell around it.
  2. "Apply it:" followed by a ` ```sh ` block with only
     `kubectl apply -f virtualservice-scout.yaml`.
  3. "Then check the result:" followed by the check commands, if any.
  The file name says the kind and the object. If a value must come from the
  reader's cluster (an IP address), use a placeholder like `<PARTNER>` in the
  YAML and say how to get the value (`echo $PARTNER`); never put shell
  variables inside YAML. Apply an object the first time its YAML appears; do
  not show it once "to read" and paste it again later. Never tell the reader
  to apply something from the playground's `examples/` folder: they start the
  playground with `astrona run`, so that folder is not on their machine.
- **Helpers have readable names.** Shell helper functions and variables use
  names that say what they do (`check_route`, `count_versions`,
  `$SERVICE_URL`), never single letters.


## About this repo (ATS101 only)

Everything above is general and can be copied to other course repositories. This
section is only true for this one.

### What the student is trying to learn

- **The goal:** master the **Project Management, RBAC & Multi-Tenancy** domain
  of the **Harbor** training path (`ATP020`). It is 20% of the path. There is
  no official Harbor certification exam; the path's domains and weights are
  Astrona's own, set in `ATP020/path.yaml`.
- **What the domain really tests:** giving several teams one Harbor without
  letting them reach each other's artifacts, and keeping each team's storage
  under control. The student must *do* things: create private projects, give
  each user or group the smallest role that works, set a storage quota, write
  retention and immutability rules, and connect Harbor to OIDC and LDAP. Every
  fix is proved with a real push or pull as the user in question, not only by
  reading a setting.
- **The four topics:**

  | Section | Title | Topic |
  | --- | --- | --- |
  | 010 | Projects And Membership | Projects and roles |
  | 020 | Quotas, Tag Retention And Immutability | Storage control |
  | 030 | Identity Integration With OIDC | OIDC |
  | 040 | Identity Integration With LDAP | LDAP and groups |

- **The versions:** **Harbor v2.15.4** (`harbor-helm` chart 1.19.4, Helm
  3.22.1) on a single-node `kind` cluster; the **`harbor` CLI v0.0.27**;
  `oras` 1.3.5 and `regctl` 0.11.7 as clients; **Keycloak 26.8.1** as the OIDC
  provider; **OpenLDAP** (`osixia/openldap:1.5.0`) as the directory. Do not
  teach fields, flags or output from other versions without saying so.
- **The main sources:** <https://goharbor.io/docs/2.15.0/>, the Harbor CLI
  pages (`doc/cli-docs/` in `goharbor/harbor-cli` at tag `v0.0.27`) and the
  REST API definition (`api/v2.0/swagger.yaml` in `goharbor/harbor` at tag
  `v2.15.4`).

### Status: built, not yet run

The first version of this repository was written from the Harbor 2.15
documentation, the CLI pages and the API definition **without a live run**.
No playground or lab has been started, and no `astrona test` has passed yet.
Until a maintainer runs them:

- Pages describe results in words. Do not add `text` output blocks until the
  output comes from a real run, and then paste it exactly.
- Treat every lab as unverified, and run `astrona validate` and
  `astrona test` on each one, one cluster at a time.
- Remove this subsection when every lab has passed `astrona test`.

The facts most likely to be wrong, in the order to check them:

1. **The scripted OIDC sign-in** (`oidc_login` in the section 030 graders):
   it follows Harbor's `/c/oidc/login` redirect, finds Keycloak's login form
   by its `login-actions/authenticate` action, posts the password, follows the
   callback, and reads `oidc_user_meta.secret` from `/api/v2.0/users/current`.
   Each step is from the documentation or the API definition, not from a run.
2. **Retention and immutable tags:** the documentation says an immutable
   artifact "cannot be deleted"; the section 020 graders assume a retention
   run therefore keeps `release-*` tags that no retain rule selects.
3. **The OpenLDAP image** fills `memberOf` through its bootstrap overlay for
   entries from the custom LDIF loaded with `--copy-service`.
4. **The `harbor` CLI** is `v0.0.x`. Pages use only commands whose flags are in
   the v0.0.27 pages (`project create`, `project member create/list/update/delete`,
   `quota list/update`, `user create`, `ldap ping/search/import`). Retention
   rules, immutability rules and system configuration go through the REST API,
   because the CLI either has no flag for them or prompts.

### Terms, not metaphors

| Term | First-use definition (example wording) |
| --- | --- |
| Project | Harbor's unit of access control and quota; every repository lives in one project |
| Public / private project | Anyone, even without signing in, can pull from a public project / only members can see a private one |
| Member, role | A user or group added to a project / the set of permissions the member gets: Project Admin, Maintainer, Developer, Guest or Limited Guest |
| Role ID | The number the REST API uses for a role: 1 Project Admin, 2 Developer, 3 Guest, 4 Maintainer, 5 Limited Guest |
| System administrator | A Harbor user with rights over every project and the system settings; only a system administrator sets quotas |
| Storage quota | The most bytes a project may store; a shared blob counts once per project |
| Tag retention rule | A rule that says which artifacts to keep in a project; a retention run deletes the rest |
| Tag immutability rule | A rule that makes matching tags impossible to overwrite or delete |
| Authentication mode | Where Harbor checks user names and passwords: its own database, LDAP, OIDC, or an HTTP authentication proxy |
| OIDC provider | The OpenID Connect server that signs users in for Harbor (Keycloak here) |
| CLI secret | A per-user password Harbor creates for OIDC users, for tools that cannot follow a browser sign-in (oras, docker, regctl) |
| Groups claim | The claim in the ID token that lists the user's groups; Harbor matches its values to OIDC groups |
| Admin group | The OIDC group or LDAP group DN whose members become Harbor system administrators |
| Onboarding | Harbor creating its own user record the first time an OIDC or LDAP user signs in |

### The example workloads

The standard Harbor environment (see `ATS100/CLAUDE.md`) plus:

| Name | Where | What it is |
| --- | --- | --- |
| Local users `alice`, `bob`, `carol`, `dan` | Harbor database (sections 010, 020) | Passwords `AlicePass1`, `BobPass1`, `CarolPass1`, `DanPass1`. Lab-only |
| Projects `team-a`, `team-b`, `inventory` | Harbor | `team-a`/`team-b` in section 010, `inventory` everywhere else |
| Repository `inventory/app` | Harbor | Tags `build-1` … `build-6`, `release-1.0` (and `release-1.1` in the capstone), small OCI artifacts pushed with `oras`, two seconds apart |
| Keycloak realm `harbor` | `keycloak` namespace, `http://keycloak.localtest.me:8180` | Client `harbor` (confidential, secret `harbor-client-secret`, redirect `https://harbor.localtest.me:8443/c/oidc/callback`, mapper that writes groups to the claim `groups`), groups `inventory-devs` (alice) and `platform-admins` (bob), user `carol` in no group |
| OpenLDAP `dc=example,dc=org` | `ldap` namespace, `ldap://openldap.ldap.svc.cluster.local:389` | Admin `cn=admin,dc=example,dc=org` / `admin-password`; users `dave`, `erin`, `frank` under `ou=people` (`DavePass1`, `ErinPass1`, `FrankPass1`); groups `inventory-devs` (dave) and `harbor-admins` (frank) under `ou=groups` |

Content is pushed and pulled with `oras` as a given user, never with Docker:
`oras login --registry-config /tmp/<user>.json -u <user> --password-stdin`.

### Environment facts the text must respect

- **Harbor images are amd64 only (seen on a live run, 2026-10-23).** On an
  arm64 machine (Apple silicon) every `goharbor/*` image runs under
  emulation. The bundled Valkey (Redis) crashes there with a segmentation
  fault, so every values file replaces it with the multi-architecture
  `docker.io/valkey/valkey:8.1.10-alpine` (`redis.internal.image`). Keep
  that override in every new values file; the other components work under
  emulation. Upgrades must keep it too: use `--reuse-values` or a values
  file that contains it.
- **Harbor, the workstation and the one-address rule** are as in ATS100:
  `https://harbor.localtest.me:8443`, the CA trusted in the workstation, the
  CoreDNS `rewrite stop` blocks. Section 030 adds a second block for
  `keycloak.localtest.me`, so Harbor and a browser reach Keycloak at the same
  address and the token issuer always matches.
- **The authentication mode can change only while the database holds no users
  except `admin`.** Sections 030 and 040 environments therefore create no
  local users. Say this every time the mode changes.
- **A browser OIDC sign-in needs both port-forwards** (`svc/harbor 8443` and
  `svc/keycloak 8180`). The graders sign in with `curl` from the workstation
  instead.
- **Quotas count shared blobs once per project**, and a push that runs over
  the quota can fail at the last step (the manifest), after the layers were
  uploaded.
- **Retention runs delete artifacts at once and cannot be undone.** Pages
  always show a dry run first. Freed space comes back after garbage
  collection.
- **Configuration through the REST API.** `PUT /api/v2.0/configurations` with
  a JSON body sets authentication; `GET` returns each key as
  `{"value": …, "editable": …}`. Pages read it with `jq`.

### Where things are in this repo

The standard layout (see ATS100). Shared environment plumbing for all twelve
environments (Helm and Harbor install, CoreDNS blocks, the workstation, the
Keycloak and OpenLDAP manifests, `prerequisites.md`, author READMEs,
`config.yaml`, seed, solution, testing and grader scripts) was generated from
one source and is identical in every environment: change a shared piece in
all of them.

### Lab metadata in `astrona.yaml`

`training:` block: id `ATS101`, domain `Project Management, RBAC &
Multi-Tenancy`, weight `20`. Lab fields in order: `title`, `path`,
`difficulty`, `estimated_duration`, `topic`, `task_kind`, `tags`,
`learning_goals`, `resources`.

- `topic`: exactly one of `projects`, `access-control`, `storage`,
  `identity`.
- `task_kind`: `build`, `troubleshooting` or `migration`.
- `tags`: 4 to 8, only from: `project`, `private-project`, `public-project`,
  `project-member`, `role-developer`, `role-guest`, `role-maintainer`,
  `role-project-admin`, `harbor-cli`, `harbor-api`, `oras`, `quota`,
  `tag-retention`, `tag-immutability`, `dry-run`, `auth-mode`, `oidc`,
  `keycloak`, `oidc-group`, `cli-secret`, `admin-group`, `onboarding`,
  `ldap`, `ldap-group`, `memberof`.
- `resources`: 1 to 4 pages on `goharbor.io`.

### Running things

```bash
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/section-010/module-01/playground
astrona destroy ats-101-playground-010-01
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/section-010/module-01/labs/lab-01
astrona submit -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-101-lab-010-01
astrona test -c sections/section-010/module-01/labs/lab-01   # authors
```

Names: `ats-101-playground-<section>-<module>`, `ats-101-lab-<section>-<module>`,
`ats-101-capstone-<section>`. Graders push and pull as the users in question
and reject the plausible but wrong fix: making a project public instead of
adding a member, giving Maintainer or Project Admin where Developer works,
deleting releases by hand instead of protecting them, removing the quota
instead of sizing it, adding users locally instead of mapping a group.

### Where to find trusted sources

- [Create projects](https://goharbor.io/docs/2.15.0/working-with-projects/create-projects/),
  [project members](https://goharbor.io/docs/2.15.0/working-with-projects/create-projects/add-users/),
  [user permissions by role](https://goharbor.io/docs/2.15.0/administration/managing-users/user-permissions-by-role/)
- [Project quotas](https://goharbor.io/docs/2.15.0/administration/configure-project-quotas/),
  [tag retention](https://goharbor.io/docs/2.15.0/working-with-projects/working-with-images/create-tag-retention-rules/),
  [tag immutability](https://goharbor.io/docs/2.15.0/working-with-projects/working-with-images/create-tag-immutability-rules/)
- [OIDC authentication](https://goharbor.io/docs/2.15.0/administration/configure-authentication/oidc-auth/),
  [LDAP authentication](https://goharbor.io/docs/2.15.0/administration/configure-authentication/ldap-auth/)
- The Harbor CLI pages: <https://goharbor.io/cli-docs/>
