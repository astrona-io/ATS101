# Sign In To Harbor With OpenID Connect

A company keeps its people in one identity provider. When someone joins, the provider gets an account and the right groups; when someone leaves, the account is disabled and every application that trusts the provider locks them out. A Harbor with its own local users does not follow along: the leaver keeps their Harbor password until someone remembers to delete it.

**OpenID Connect (OIDC)** is a sign-in protocol on top of OAuth 2.0. Harbor redirects the browser to the **OIDC provider**, the provider checks the password, and Harbor receives an **ID token**, a signed JSON Web Token (JWT) that says who the user is and, here, which groups they are in. Keep one sentence in mind: **with OIDC, Keycloak decides who you are and which groups you are in, and Harbor decides what those groups may do.**

The module has three parts. **Authentication Modes And When You Can Change Them** reads Harbor's current mode and the rule that limits changing it. **Configuring Harbor For Keycloak** switches Harbor to OIDC and signs a user in through the browser. **OIDC Groups, The Admin Group And CLI Secrets** turns Keycloak groups into project access and administrator rights, and shows how `oras` signs in. A graded lab follows the third part.

## Learning objectives

After this module you can:

- Name Harbor's authentication modes, and explain when the mode can be changed.
- Read an OIDC provider's discovery document and find the issuer.
- Configure Harbor for an OIDC provider through the REST API, and test the endpoint.
- Explain automatic onboarding and the username claim.
- Make an OIDC group a member of a project, and set the admin group.
- Explain what a CLI secret is, and sign a registry client in with one.

## Before you start

You need to know what a Harbor project, a member and a role are. You should know what OAuth 2.0 and OpenID Connect are for, at the level of "the provider signs the user in and gives the application a token"; this module explains the parts Harbor uses.

Your playground is a single-node `kind` cluster with **Harbor v2.15.4** at `https://harbor.localtest.me:8443` and **Keycloak 26.8.1** at `http://keycloak.localtest.me:8180`. Both addresses work inside the cluster, and on your machine through a port-forward. The `workstation` pod holds the `harbor` CLI, `oras`, `curl` and `jq`, and trusts Harbor's certificate. The playground holds:

| Object | Where | What it is |
| --- | --- | --- |
| `admin` | Harbor | The system administrator, lab-only password `Harbor12345`; the only Harbor user |
| `inventory` | Harbor | A private project with no members except `admin` |
| Realm `harbor` | Keycloak | The realm Harbor signs users in with |
| Client `harbor` | Keycloak | Confidential client, secret `harbor-client-secret`, redirect URI `https://harbor.localtest.me:8443/c/oidc/callback`, with a mapper that puts the user's groups in the claim `groups` |
| `alice`, `bob`, `carol` | Keycloak | Users with the lab-only passwords `AlicePass1`, `BobPass1`, `CarolPass1`; `alice` is in `inventory-devs`, `bob` in `platform-admins`, `carol` in no group |

The Keycloak administrator is `admin` with the lab-only password `admin`.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
