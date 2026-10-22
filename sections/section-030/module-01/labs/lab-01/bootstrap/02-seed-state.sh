#!/usr/bin/env bash
# Creates the starting state for ats-101-lab-030-01: creates the Keycloak realm harbor with the client, groups and users, and the Harbor project inventory; Harbor still uses database authentication.
#
# The fix is NOT applied here — producing it is the task.
set -euo pipefail

# --- shared helpers (same in every ATS101 environment) ---
HARBOR_URL="https://harbor.localtest.me:8443"
HARBOR_HOST="harbor.localtest.me:8443"
ADMIN_USER="admin"
ADMIN_PASSWORD="Harbor12345"   # lab-only chart default

ws() { kubectl -n workstation exec -i deploy/workstation -- "$@"; }

# harbor_api METHOD PATH [JSON]: calls the Harbor REST API v2.0 as admin from
# the workstation pod. Prints the response body; fails on HTTP errors.
harbor_api() {
  local method="$1" path="$2" body="${3:-}"
  if [ -n "$body" ]; then
    printf '%s' "$body" | ws curl -sS -f -u "$ADMIN_USER:$ADMIN_PASSWORD" -X "$method" \
      -H 'Content-Type: application/json' --data-binary @- "$HARBOR_URL/api/v2.0$path"
  else
    ws curl -sS -f -u "$ADMIN_USER:$ADMIN_PASSWORD" -X "$method" "$HARBOR_URL/api/v2.0$path"
  fi
}

# harbor_status METHOD PATH [JSON]: like harbor_api, but prints only the HTTP code.
harbor_status() {
  local method="$1" path="$2" body="${3:-}"
  if [ -n "$body" ]; then
    printf '%s' "$body" | ws curl -sS -o /dev/null -w '%{http_code}' -u "$ADMIN_USER:$ADMIN_PASSWORD" \
      -X "$method" -H 'Content-Type: application/json' --data-binary @- "$HARBOR_URL/api/v2.0$path"
  else
    ws curl -sS -o /dev/null -w '%{http_code}' -u "$ADMIN_USER:$ADMIN_PASSWORD" -X "$method" "$HARBOR_URL/api/v2.0$path"
  fi
}

# create_user NAME PASSWORD: creates a local Harbor user if it does not exist.
create_user() {
  local name="$1" password="$2"
  [ "$(harbor_status GET "/users/search?username=$name" )" = "200" ] && \
    harbor_api GET "/users/search?username=$name" | grep -q "\"username\":\"$name\"" && return 0
  harbor_api POST /users "{\"username\":\"$name\",\"email\":\"$name@example.com\",\"realname\":\"$name\",\"password\":\"$password\",\"comment\":\"lab user\"}" >/dev/null
}

# create_project NAME PUBLIC(true|false): creates a project if it does not exist.
create_project() {
  local name="$1" public="$2"
  [ "$(harbor_status HEAD "/projects?project_name=$name")" = "200" ] && return 0
  harbor_api POST /projects "{\"project_name\":\"$name\",\"metadata\":{\"public\":\"$public\"}}" >/dev/null
}

# push_as USER PASSWORD REF [SIZE_BYTES]: pushes a small file (or a random file
# of SIZE_BYTES) as an OCI artifact with oras, signed in as USER. Exit code 0
# means the push succeeded. USER "-" pushes without signing in.
push_as() {
  local user="$1" password="$2" ref="$3" size="${4:-}"
  printf '%s' "$password" | ws sh -c '
    user="$1"; ref="$2"; size="$3"; cfg="/tmp/oras-$user.json"; rm -f "$cfg"
    if [ "$user" != "-" ]; then
      oras login --registry-config "$cfg" -u "$user" --password-stdin "'"$HARBOR_HOST"'" >/dev/null 2>&1 || exit 3
    fi
    dir="$(mktemp -d)"; cd "$dir"
    if [ -n "$size" ]; then head -c "$size" /dev/urandom > payload.bin; else printf "%s %s\n" "$ref" "$(cat /proc/sys/kernel/random/uuid)" > payload.bin; fi
    oras push --registry-config "$cfg" "$ref" payload.bin >/dev/null 2>&1
  ' sh "$user" "$ref" "$size"
}

# pull_as USER PASSWORD REF: pulls an artifact with oras. Exit code 0 means it worked.
pull_as() {
  local user="$1" password="$2" ref="$3"
  printf '%s' "$password" | ws sh -c '
    user="$1"; ref="$2"; cfg="/tmp/oras-$user.json"; rm -f "$cfg"
    if [ "$user" != "-" ]; then
      oras login --registry-config "$cfg" -u "$user" --password-stdin "'"$HARBOR_HOST"'" >/dev/null 2>&1 || exit 3
    fi
    dir="$(mktemp -d)"; cd "$dir"
    oras pull --registry-config "$cfg" "$ref" >/dev/null 2>&1
  ' sh "$user" "$ref"
}

# list_tags PROJECT REPOSITORY: prints the tags in a repository, one per line.
list_tags() {
  harbor_api GET "/projects/$1/repositories/$2/artifacts?with_tag=true&page_size=100" \
    | ws jq -r '.[].tags[]?.name' | sort
}

pass() { echo "PASS: $*"; exit 0; }
fail() { echo "FAIL: $*"; exit 1; }
# --- end of shared helpers ---
# --- Keycloak helpers ---
kcadm() {
  kubectl -n keycloak exec -i deploy/keycloak -- \
    /opt/keycloak/bin/kcadm.sh "$@" --config /tmp/kcadm.config
}
kcadm_login() {
  for _ in $(seq 1 30); do
    kcadm config credentials --server http://localhost:8080 --realm master \
      --user admin --password admin >/dev/null 2>&1 && return 0
    sleep 5
  done
  return 1
}
# --- end of Keycloak helpers ---

echo "[lab] Creating the starting state..."
kcadm_login || fail "could not sign kcadm in to Keycloak."
kcadm get realms/harbor >/dev/null 2>&1 || kcadm create realms -s realm=harbor -s enabled=true
if [ -z "$(kcadm get clients -r harbor -q clientId=harbor --fields id --format csv --noquotes)" ]; then
  kcadm create clients -r harbor -s clientId=harbor -s enabled=true -s publicClient=false \
    -s secret=harbor-client-secret -s standardFlowEnabled=true -s directAccessGrantsEnabled=false \
    -s 'redirectUris=["https://harbor.localtest.me:8443/c/oidc/callback"]' -s 'webOrigins=["https://harbor.localtest.me:8443"]'
fi
client_id="$(kcadm get clients -r harbor -q clientId=harbor --fields id --format csv --noquotes)"
# A group membership mapper puts the user's group names in the claim "groups".
if ! kcadm get "clients/$client_id/protocol-mappers/models" -r harbor | grep -q '"name" : "groups"'; then
  kcadm create "clients/$client_id/protocol-mappers/models" -r harbor -s name=groups \
    -s protocol=openid-connect -s protocolMapper=oidc-group-membership-mapper \
    -s 'config."claim.name"=groups' -s 'config."full.path"=false' \
    -s 'config."id.token.claim"=true' -s 'config."access.token.claim"=true' -s 'config."userinfo.token.claim"=true'
fi
for group in inventory-devs platform-admins; do
  [ -n "$(kcadm get groups -r harbor -q search=$group --fields id --format csv --noquotes)" ] || \
    kcadm create groups -r harbor -s name=$group
done
add_kc_user() {  # NAME PASSWORD GROUP(or -)
  if [ -z "$(kcadm get users -r harbor -q username=$1 -q exact=true --fields id --format csv --noquotes)" ]; then
    kcadm create users -r harbor -s username=$1 -s enabled=true -s email=$1@example.com \
      -s emailVerified=true -s firstName=$1 -s lastName=Example
    kcadm set-password -r harbor --username $1 --new-password $2
  fi
  if [ "$3" != "-" ]; then
    local user_id group_id
    user_id="$(kcadm get users -r harbor -q username=$1 -q exact=true --fields id --format csv --noquotes)"
    group_id="$(kcadm get groups -r harbor -q search=$3 --fields id --format csv --noquotes | head -1)"
    kcadm update "users/$user_id/groups/$group_id" -r harbor -s realm=harbor -s userId=$user_id -s groupId=$group_id -n
  fi
}
add_kc_user alice AlicePass1 inventory-devs
add_kc_user bob BobPass1 platform-admins
add_kc_user carol CarolPass1 -
create_project inventory false

echo "[lab] Starting state ready."
