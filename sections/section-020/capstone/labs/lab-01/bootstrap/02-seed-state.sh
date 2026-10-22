#!/usr/bin/env bash
# Creates the starting state for ats-101-capstone-020: creates inventory with builds and two releases, a 5 MiB quota and a retention policy that keeps only one artifact.
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

echo "[lab] Creating the starting state..."
create_project inventory false
for n in 1 2 3 4 5 6; do
  push_as "$ADMIN_USER" "$ADMIN_PASSWORD" "$HARBOR_HOST/inventory/app:build-$n"
  sleep 2
done
push_as "$ADMIN_USER" "$ADMIN_PASSWORD" "$HARBOR_HOST/inventory/app:release-1.0"
push_as "$ADMIN_USER" "$ADMIN_PASSWORD" "$HARBOR_HOST/inventory/app:release-1.1"
pid="$(harbor_api GET /projects/inventory | ws jq -r '.project_id')"
qid="$(harbor_api GET "/quotas?reference=project&reference_id=$pid" | ws jq -r '.[0].id')"
harbor_api PUT "/quotas/$qid" '{"hard":{"storage":5242880}}' >/dev/null
harbor_api POST /retentions "{\"algorithm\":\"or\",\"rules\":[{\"disabled\":false,\"action\":\"retain\",\"template\":\"latestPushedK\",\"params\":{\"latestPushedK\":1},\"tag_selectors\":[{\"kind\":\"doublestar\",\"decoration\":\"matches\",\"pattern\":\"**\"}],\"scope_selectors\":{\"repository\":[{\"kind\":\"doublestar\",\"decoration\":\"repoMatches\",\"pattern\":\"**\"}]}}],\"trigger\":{\"kind\":\"Schedule\",\"settings\":{\"cron\":\"0 0 3 * * *\"}},\"scope\":{\"level\":\"project\",\"ref\":$pid}}" >/dev/null

echo "[lab] Starting state ready."
