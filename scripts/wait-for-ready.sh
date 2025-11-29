#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Waiting for Kubernetes API..."

# Check kubectl client exists
kubectl version --client >/dev/null 2>&1

# Check cluster API is reachable
for i in {1..15}; do
  if kubectl get --raw='/healthz' 2>/dev/null | grep ok >/dev/null; then
    echo "✅ Kubernetes API reachable"
    break
  fi
  echo "⏳ Kubernetes API not ready yet..."
  sleep 2
done

if ! kubectl get --raw='/healthz' 2>/dev/null | grep ok >/dev/null; then
  echo "❌ Kubernetes API not responding"
  exit 1
fi

echo "✅ Kubernetes API reachable"

echo "⏳ Waiting for ingress-nginx controller..."
kubectl -n ingress-nginx wait \
  --for=condition=available \
  deployment/ingress-nginx-controller \
  --timeout=180s

echo "✅ ingress-nginx controller is ready"

echo "⏳ Waiting for application deployments..."
kubectl wait \
  --for=condition=available \
  deployment/foo deployment/bar \
  --timeout=120s

echo "✅ foo and bar deployments are ready"

echo "⏳ Waiting for ingress resource..."
for i in {1..30}; do
  kubectl get ingress echo-ingress >/dev/null 2>&1 && break
  sleep 2
done

kubectl get ingress echo-ingress >/dev/null 2>&1 || {
  echo "❌ ingress resource not found"
  exit 1
}

echo "✅ ingress resource exists"

echo "🌐 Verifying HTTP routing through ingress..."

check_route () {
  local host=$1
  local expected=$2

  for i in {1..15}; do
    response=$(curl -s -H "Host: ${host}" http://localhost || true)
    if [[ "$response" == "$expected" ]]; then
      echo "✅ ${host} routing OK"
      return 0
    fi
    sleep 2
  done

  echo "❌ Routing failed for ${host}"
  exit 1
}

check_route "foo.localhost" "foo"
check_route "bar.localhost" "bar"

echo "🎉 All workloads and routing are healthy"
