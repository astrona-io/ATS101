# Summary

Harbor checks passwords in one of four places, set by the authentication mode: its own database (`db_auth`), an LDAP server (`ldap_auth`), an OpenID Connect provider (`oidc_auth`) or an HTTP authentication proxy (`http_auth`). The mode can change only while the database holds no users except `admin`, because a local user and a provider user with the same name would be two different people. The configuration shows this with the `editable` flag of `auth_mode`.

With OIDC, Harbor sends the browser to the provider, the provider checks the password, and Harbor exchanges the returned code for an ID token, using its client secret. Harbor needs the provider's issuer as the endpoint, the client ID and secret, a scope that includes `openid`, and a redirect URI registered at the provider that matches Harbor's address exactly, port included. The provider must be reachable under the same name from the browser and from Harbor. The `ping` call tests the endpoint from Harbor itself. With automatic onboarding, Harbor creates the user at the first sign-in and takes the name from the username claim.

Access comes from groups. The provider puts the user's groups in a claim, Harbor reads the claim named in its groups claim setting, and an OIDC group, type `3`, can be a project member with a role. One admin group makes its members Harbor administrators. Registry clients cannot follow a browser sign-in, so each OIDC user has a CLI secret to use as the password; it works only while Harbor can refresh the user's session. The key facts to remember are these:

- Switch the authentication mode before any local user exists.
- The redirect URI and the issuer must match exactly.
- Map groups, not people, to project roles.
- `oras` and `docker` sign in with the CLI secret, not the provider password.

<!-- astrona:playground:destroy -->
