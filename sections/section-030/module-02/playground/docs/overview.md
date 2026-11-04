# Overview: Operate And Troubleshoot OIDC Sign-In (Playground)

This is a **playground**, not a lab. It starts a fresh cluster, installs Harbor, Keycloak and the workstation, prepares a Keycloak realm, and switches Harbor to OpenID Connect (OIDC) sign-in. There is no task, no `astrona submit` and no pass or fail. Explore, change things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` Kubernetes cluster. `kubectl` is already pointed at it.
- **Harbor v2.15.4** at `https://harbor.localtest.me:8443`, already in OIDC mode with Keycloak. The built-in `admin` (`Harbor12345`) still signs in with its database password. The private projects `reports` and `inventory` each hold one artifact.
- **Keycloak 26.8.1** at `http://keycloak.localtest.me:8180`, administrator `admin` with the lab-only password `admin`. The realm `harbor` holds:
  - the confidential client `harbor`, secret `harbor-client-secret`, with a mapper that writes the user's groups to the claim `groups`;
  - the groups `report-writers`, `report-readers` and `platform-admins`;
  - the users `alice` (`AlicePass1`, in `report-writers`), `carol` (`CarolPass1`, in `report-readers`) and `bob` (`BobPass1`, in `platform-admins`).
- Harbor's OIDC settings: the groups claim is `groups`, the admin group is `platform-admins`, automatic onboarding is on and the user claim is `preferred_username`.
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

## Practice tasks

- Read the discovery document of the realm with `curl` and `jq`.
- Add `report-writers` and `report-readers` to `reports` with different roles, then sign in as each user in a browser and compare what they can do.
- Move `carol` to another group in Keycloak and see when Harbor notices.
- Break one setting, such as the groups claim, and follow the troubleshooting method until you find it.
