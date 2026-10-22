# Section 030: Identity Integration With OIDC

Creating every user by hand in Harbor does not scale, and it leaves a second password for every person to forget and for you to revoke. Most companies already have an identity provider. With **OpenID Connect (OIDC)**, Harbor sends users to that provider to sign in, creates its own user record from the provider's answer, and reads the user's groups from it.

This section connects Harbor to Keycloak, an OIDC provider running in the same cluster. You switch Harbor's authentication mode, configure the client, let users onboard automatically, make an OIDC group a project member, make another group Harbor administrators, and give registry clients a **CLI secret**, because a tool like `oras` cannot follow a browser sign-in.

**Topic covered:** Identity integration with OIDC

## What you will learn

- Harbor's authentication modes, and the rule that decides when you can change the mode.
- What Harbor needs from an OIDC provider: an endpoint, a client, a redirect URI and claims.
- Configuring OIDC through the REST API, and testing the endpoint before you save.
- Automatic onboarding and the username claim.
- OIDC groups as project members, and the admin group.
- CLI secrets: what they are, where a user finds one, and how a registry client uses it.

## The learning path

### 1. Sign In To Harbor With OpenID Connect

The module starts at its landing page, which also launches the playground. The playground holds Harbor, still on database authentication with no users except `admin`, and Keycloak with the realm `harbor`, a client for Harbor, two groups and three users.

1. Authentication Modes And When You Can Change Them
2. Configuring Harbor For Keycloak
3. OIDC Groups, The Admin Group And CLI Secrets, followed by the lab **Connect Harbor To Keycloak And Map A Group**
4. Summary

## Section capstone: Repair A Broken OIDC Sign-In

The capstone is one graded scenario that combines the whole module. Harbor is already in OIDC mode, but nobody can sign in, groups never arrive, and the platform team is not administrator. The faults are split between Harbor's settings and the Keycloak client. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/section-030/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-030/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-101-capstone-030
```
