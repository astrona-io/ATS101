# Operate And Troubleshoot OIDC Sign-In

An OpenID Connect (OIDC) setup that works on the first day is only the beginning. Teams change, people move between groups, a secret has to be replaced, and one morning nobody can sign in. The person who runs Harbor must know what Harbor reads from the identity provider, how groups turn into rights, and where to look when a step fails.

An **ID token** is a signed JSON Web Token (JWT) that the OIDC provider gives to Harbor after a user signs in. It holds **claims**, which are named facts about the user, such as the user name, the email address and the groups. Keep one sentence in mind for the whole module: **Harbor trusts the claims in the ID token at sign-in, and everything it knows about a user's groups is as old as the last sign-in.**

The module has four parts. **What Harbor Reads From The ID Token** shows the claims and how Harbor identifies a user. **Designing Group To Role Mappings** assigns different roles to different groups. **Tokens, Sessions And CLI Secrets** covers the lifetime of the access a user holds. **Troubleshooting OIDC Sign-In** gives a method for finding the failing step. A graded lab follows the second part.

## Learning objectives

After this module you can:

- Read the discovery document of an OIDC provider and name the issuer.
- Name the claims Harbor uses and the setting that selects each one.
- Explain how Harbor identifies a returning user.
- Give two groups different roles in the same project and prove the difference.
- Explain when a change of group in the provider reaches Harbor.
- Set and replace a CLI secret, and explain why a pipeline should use a robot account instead.
- Find the failing step of a broken sign-in from the symptom and the Harbor core log.

## Before you start

You need to know how Harbor connects to an OIDC provider, what a group member is, and what the five project roles allow. This module starts with Harbor already connected.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** at `https://harbor.localtest.me:8443` and **Keycloak 26.8.1** at `http://keycloak.localtest.me:8180`. The `workstation` pod holds the `harbor` CLI, `oras`, `curl` and `jq`, and trusts Harbor's certificate. The playground holds:

| Object | Where | What it is |
| --- | --- | --- |
| `admin` | Harbor | The system administrator, lab-only password `Harbor12345` |
| `reports`, `inventory` | Harbor | Private projects, each with one artifact |
| Realm `harbor` | Keycloak | The realm Harbor signs users in with; Harbor is already in OIDC mode with it |
| Client `harbor` | Keycloak | Confidential client with a mapper that puts the groups in the claim `groups` |
| `alice`, `bob`, `carol` | Keycloak | Users with the lab-only passwords `AlicePass1`, `BobPass1`, `CarolPass1`; `alice` is in `report-writers`, `carol` in `report-readers`, `bob` in `platform-admins` |

The Keycloak administrator is `admin` with the lab-only password `admin`.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
