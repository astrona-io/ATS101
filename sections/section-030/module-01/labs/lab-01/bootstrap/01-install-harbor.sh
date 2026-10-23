#!/usr/bin/env bash
# Installs Helm, Harbor 2.15.4, the extra services and the workstation pod for ats-101-lab-030-01.
#
# Graded lab bootstrap: this prepares the environment ONLY. It never creates
# the objects the task asks for.
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

TAG="lab"
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
        print "    rewrite stop {"
        print "        name regex keycloak\\.localtest\\.me keycloak.keycloak.svc.cluster.local"
        print "        answer name keycloak\\.keycloak\\.svc\\.cluster\\.local keycloak.localtest.me"
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

echo "[$TAG] Starting Keycloak 26.8.1 (this can take a few minutes)..."
kubectl apply -f "$MANIFEST_DIR/keycloak.yaml"
kubectl -n keycloak rollout status deployment/keycloak --timeout=600s

# lab-start.yaml is also listed under bootstrap.manifests in config.yaml, so it
# may already be applied. kubectl apply is idempotent.
echo "[$TAG] Starting the workstation pod..."
kubectl apply -f "$MANIFEST_DIR/lab-start.yaml"
kubectl -n workstation rollout status deployment/workstation --timeout=600s
for _ in $(seq 1 60); do
  kubectl -n workstation exec deploy/workstation -- test -s /usr/local/share/ca-certificates/harbor-ca.crt 2>/dev/null && break
  sleep 5
done

echo "[lab] Harbor ready."
