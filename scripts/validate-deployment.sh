#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="${APP_NAME:-git-workshop}"
PROJECT="${PROJECT:-$(oc project -q 2>/dev/null || true)}"

[[ -n "${PROJECT}" ]] || { echo 'Set PROJECT or select an OpenShift project.' >&2; exit 1; }
oc project "${PROJECT}" >/dev/null

oc get buildconfig "${APP_NAME}" >/dev/null
oc get imagestream "${APP_NAME}" >/dev/null
oc get deployment "${APP_NAME}" >/dev/null
oc get service "${APP_NAME}" >/dev/null
oc get route "${APP_NAME}" >/dev/null

oc rollout status "deployment/${APP_NAME}" --timeout=5m

ready="$(oc get deployment "${APP_NAME}" -o jsonpath='{.status.readyReplicas}')"
[[ "${ready:-0}" -ge 1 ]] || { echo 'Deployment has no ready replicas.' >&2; exit 1; }

endpoints="$(oc get endpoints "${APP_NAME}" -o jsonpath='{.subsets[*].addresses[*].ip}')"
[[ -n "${endpoints}" ]] || { echo 'Service has no ready endpoints.' >&2; exit 1; }

route_host="$(oc get route "${APP_NAME}" -o jsonpath='{.spec.host}')"
url="https://${route_host}"

curl --fail --silent --show-error --insecure "${url}/healthz" >/dev/null

printf '[OK] Deployment ready replicas: %s\n' "${ready}"
printf '[OK] Service endpoints: %s\n' "${endpoints}"
printf '[OK] Health endpoint: %s/healthz\n' "${url}"
printf '[OK] Application: %s\n' "${url}"
