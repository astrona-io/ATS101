#!/usr/bin/env bash
# OS prep for the "Control Storage With Quotas, Retention And Immutability" playground (`ats-101-playground-020-01`).
#
# Environment preparation only. There is no task and no grading. It installs
# Harbor and the module's starting state; see config.yaml for the summary.
set -euo pipefail
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

TAG="playground"
HELM_VERSION="3.22.1"
HARBOR_CHART_VERSION="1.19.4"

BIN_DIR="/usr/local/bin"
[ -w "$BIN_DIR" ] || BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# Pin Helm rather than accepting whatever is on the machine: the Harbor
# documentation is written for Helm 3.
have_version=""
command -v helm >/dev/null 2>&1 && \
  have_version=$(helm version --template '{{.Version}}' 2>/dev/null | sed 's/^v//')
if [ "$have_version" != "$HELM_VERSION" ]; then
  OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"
  case "$ARCH" in x86_64) ARCH=amd64 ;; aarch64|arm64) ARCH=arm64 ;; esac
  WORK="$(mktemp -d)"
  trap 'rm -rf "$WORK"' EXIT
  echo "[$TAG] Downloading Helm ${HELM_VERSION} (${OS}/${ARCH})..."
  curl -fsSL "https://get.helm.sh/helm-v${HELM_VERSION}-${OS}-${ARCH}.tar.gz" | tar -xz -C "$WORK"
  install -m 0755 "$WORK/${OS}-${ARCH}/helm" "$BIN_DIR/helm"
fi
helm version --short

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST_DIR=""
for candidate in "$SCRIPT_DIR/../manifests" "./manifests" "$SCRIPT_DIR/manifests"; do
  [ -d "$candidate" ] && { MANIFEST_DIR="$candidate"; break; }
done

# One address for the reader's machine and the cluster: each *.localtest.me
# name resolves to 127.0.0.1 on the machine (reached through a port-forward),
# and these CoreDNS blocks send the same name to the Service in the cluster.
# The answer is rewritten back to the asked name: Go programs ignore DNS
# answers whose name differs from the question.
if ! kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' | grep -q "harbor.localtest.me"; then
  echo "[$TAG] Adding the CoreDNS rewrites..."
  COREFILE="$(kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' \
    | awk '/^[[:space:]]*kubernetes / && !done {
        print "    rewrite stop {"
        print "        name regex harbor\\.localtest\\.me harbor.harbor.svc.cluster.local"
        print "        answer name harbor\\.harbor\\.svc\\.cluster\\.local harbor.localtest.me"
        print "    }"
        done=1
      } {print}')"
  kubectl -n kube-system create configmap coredns --from-literal=Corefile="$COREFILE" \
    --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n kube-system rollout restart deployment/coredns
  kubectl -n kube-system rollout status deployment/coredns --timeout=120s
fi

echo "[$TAG] Installing Harbor (chart ${HARBOR_CHART_VERSION}); this takes several minutes..."
helm repo add harbor https://helm.goharbor.io >/dev/null 2>&1 || true
helm repo update harbor >/dev/null
helm upgrade --install harbor harbor/harbor --version "$HARBOR_CHART_VERSION" \
  --namespace harbor --create-namespace \
  --values "$MANIFEST_DIR/harbor-values.yaml" \
  --wait --timeout 20m

# lab-start.yaml is also listed under bootstrap.manifests in config.yaml, so it
# may already be applied. kubectl apply is idempotent.
echo "[$TAG] Starting the workstation pod..."
kubectl apply -f "$MANIFEST_DIR/lab-start.yaml"
kubectl -n workstation rollout status deployment/workstation --timeout=600s
for _ in $(seq 1 60); do
  kubectl -n workstation exec deploy/workstation -- test -s /usr/local/share/ca-certificates/harbor-ca.crt 2>/dev/null && break
  sleep 5
done

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

echo "[playground] Creating the starting state..."
create_project inventory false
for n in 1 2 3 4 5 6; do
  push_as "$ADMIN_USER" "$ADMIN_PASSWORD" "$HARBOR_HOST/inventory/app:build-$n"
  sleep 2
done
push_as "$ADMIN_USER" "$ADMIN_PASSWORD" "$HARBOR_HOST/inventory/app:release-1.0"

echo "[playground] Ready."
kubectl -n harbor get pods
echo "[playground] Run tools in the workstation: kubectl -n workstation exec -it deploy/workstation -- sh"
echo "[playground] Harbor web portal: kubectl -n harbor port-forward svc/harbor 8443:8443, then https://harbor.localtest.me:8443"
