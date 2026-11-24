#!/usr/bin/env bash
# Creates a self-signed TLS certificate and stores it as a Kubernetes TLS secret.
# For a real domain, use cert-manager + Let's Encrypt instead (see README).
set -euo pipefail

HOST="${1:-wisecow.local}"
NAMESPACE="${2:-default}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout "$TMP/tls.key" -out "$TMP/tls.crt" \
  -subj "/CN=${HOST}/O=wisecow" \
  -addext "subjectAltName=DNS:${HOST}"

kubectl create secret tls wisecow-tls \
  --cert="$TMP/tls.crt" --key="$TMP/tls.key" \
  --namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "TLS secret 'wisecow-tls' created for ${HOST}"
