# Overview: Sign In To Harbor With OpenID Connect (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor, Keycloak and the workstation, prepares a Keycloak realm for Harbor, and then waits. There is no task, no `astrona submit` and no pass or fail. Explore, change things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** at `https://harbor.localtest.me:8443`, still on database authentication. Its only user is `admin` with the lab-only password `Harbor12345`. The private project `inventory` exists.
- **Keycloak 26.8.1** at `http://keycloak.localtest.me:8180`, administrator `admin` with the lab-only password `admin`. The realm `harbor` holds:
  - the confidential client `harbor`, secret `harbor-client-secret`, redirect URI `https://harbor.localtest.me:8443/c/oidc/callback`, with a mapper that writes the user's groups to the claim `groups`;
  - the groups `inventory-devs` and `platform-admins`;
  - the users `alice` (`AlicePass1`, in `inventory-devs`), `bob` (`BobPass1`, in `platform-admins`) and `carol` (`CarolPass1`, in no group).
- The **workstation** pod with the `harbor` CLI v0.0.27, `oras`, `curl` and `jq`, trusting Harbor's certificate.

For a browser sign-in, run both port-forwards in two extra terminals: `kubectl -n harbor port-forward svc/harbor 8443:8443` and `kubectl -n keycloak port-forward svc/keycloak 8180:8180`. If `harbor.localtest.me` or `keycloak.localtest.me` does not resolve on your machine, add `127.0.0.1 harbor.localtest.me keycloak.localtest.me` to `/etc/hosts`.

## Helpers

Paste these once in each new terminal. `ws` runs a command in the workstation, `kcadm` runs Keycloak's administration tool in the Keycloak pod, and `harbor_setting` prints one value of Harbor's configuration.

```sh
ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }
kcadm() { kubectl -n keycloak exec -i deploy/keycloak -- /opt/keycloak/bin/kcadm.sh "$@" --config /tmp/kcadm.config; }
harbor_setting() {
  ws sh -c "curl -s -u admin:Harbor12345 https://harbor.localtest.me:8443/api/v2.0/configurations | jq -r '.$1.value'"
}
kcadm config credentials --server http://localhost:8080 --realm master --user admin --password admin
```

Use them like this: `harbor_setting auth_mode`, `kcadm get groups -r harbor`.

## Practice tasks

- Before switching the mode, create a local user with `ws harbor user create --username test --password TestPass1 --email test@example.com --realname Test` and read `editable` of `auth_mode`. Delete the user and read it again.
- Switch Harbor to OIDC with automatic onboarding off. Sign in as `carol` in the browser and see what Harbor asks for.
- Change `oidc_groups_claim` to `group`, sign in as `alice`, and check whether her push to `inventory` still works.
- Change the client's redirect URI in Keycloak to one without the port and try a browser sign-in. Read the error page Keycloak shows.
- Create a new CLI secret for `alice` in her user profile and check that the old one no longer works with `oras login`.
