# Summary

Harbor trusts the claims in the ID token at sign-in. It reads the subject and the issuer to recognise a returning user, the username claim to name a new user, and the groups claim to learn the user's groups. The subject and issuer pair stays the same when a user name changes in the provider. The discovery document of the provider shows the issuer, and Harbor's endpoint must match it exactly.

Groups become access when an administrator adds them as project members with a role. An OIDC group has the type `3`. Two groups can have different roles in the same project, and each person is best placed in one group per project. Harbor learns a user's groups at each sign-in only, so a change in the provider reaches Harbor at the next sign-in, and an immediate effect needs a change in Harbor or a disabled user.

Access has three lifetimes: the portal session, the short registry token set by `token_expiration`, and the CLI secret that depends on Harbor being able to refresh the user's tokens at the provider. An administrator can replace a CLI secret through the REST API, but automation should use robot accounts. When sign-in breaks, test the endpoint from Harbor with the ping call, find the failing step, read the Harbor core log and change one thing at a time. The key facts to remember are these:

- Harbor identifies a user by subject and issuer, not by name.
- Group changes in the provider take effect at the next sign-in.
- CLI secrets are for people; robot accounts are for pipelines.
- The core log holds the reason that the portal does not show.

<!-- astrona:playground:destroy -->
