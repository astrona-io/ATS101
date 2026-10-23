#!/usr/bin/env bash
# Confirms bob has no access to team-a and keeps Developer on team-b.
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

if pull_as bob BobPass1 "$HARBOR_HOST/team-a/app:1.0"; then fail "bob can still pull from team-a."; fi
push_as bob BobPass1 "$HARBOR_HOST/team-b/app:bob" || fail "bob lost push access to team-b."
pass "bob reaches team-b only."
