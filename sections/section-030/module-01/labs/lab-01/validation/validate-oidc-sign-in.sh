#!/usr/bin/env bash
# Signs alice in through Keycloak, then pushes with her CLI secret; carol's push is refused.
set -uo pipefail
# grep -q stops reading at the first match; under pipefail the command
# writing into the pipe then fails with SIGPIPE and a match looks like a
# failure. This wrapper reads all input instead and keeps grep's exit status.
grep() {
  local arg quiet=0 args=()
  for arg in "$@"; do
    case "$arg" in
      --quiet|--silent) quiet=1 ;;
      --*) args+=("$arg") ;;
      -*q*) quiet=1; [ "$arg" = "-q" ] || args+=("${arg//q/}") ;;
      *) args+=("$arg") ;;
    esac
  done
  if [ "$quiet" = 1 ]; then command grep "${args[@]}" >/dev/null; else command grep "$@"; fi
}

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
# oidc_login USER PASSWORD: signs USER in to Harbor through Keycloak with curl
# (the same redirects a browser follows) and prints the user's CLI secret.
oidc_login() {
  printf '%s' "$2" | ws sh -c '
    user="$1"; password="$(cat)"; jar="$(mktemp)"; base="'"$HARBOR_URL"'"
    # 1. Harbor redirects to the Keycloak sign-in page.
    auth_url="$(curl -s -c "$jar" -b "$jar" -o /dev/null -w "%{redirect_url}" "$base/c/oidc/login")"
    [ -n "$auth_url" ] || exit 2
    page="$(curl -s -c "$jar" -b "$jar" "$auth_url")"
    action="$(printf "%s" "$page" | grep -o "action=\"[^\"]*login-actions/authenticate[^\"]*\"" | head -1 | sed "s/^action=\"//; s/\"$//; s/&amp;/\\&/g")"
    [ -n "$action" ] || exit 3
    # 2. Keycloak checks the password and redirects back to Harbor with a code.
    callback="$(curl -s -c "$jar" -b "$jar" -o /dev/null -w "%{redirect_url}" \
      --data-urlencode "username=$user" --data-urlencode "password=$password" "$action")"
    case "$callback" in "$base"/c/oidc/callback*) ;; *) exit 4 ;; esac
    # 3. Harbor exchanges the code with the client secret and starts a session.
    curl -s -L -c "$jar" -b "$jar" -o /dev/null "$callback"
    curl -s -f -b "$jar" "$base/api/v2.0/users/current" | jq -er ".oidc_user_meta.secret"
  ' sh "$1"
}

secret="$(oidc_login alice AlicePass1)" || fail "alice could not sign in to Harbor through Keycloak (step $?)."
[ -n "$secret" ] || fail "alice signed in but has no CLI secret."
push_as alice "$secret" "$HARBOR_HOST/inventory/app:alice" || fail "alice signed in but cannot push to inventory with her CLI secret."
carol_secret="$(oidc_login carol CarolPass1)" || fail "carol could not sign in to Harbor through Keycloak."
if push_as carol "$carol_secret" "$HARBOR_HOST/inventory/app:carol"; then fail "carol, who is in no group, can push to inventory."; fi
pass "OIDC sign-in works end to end, and only members of inventory-devs can push."
