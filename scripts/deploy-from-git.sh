#!/usr/bin/env bash
set -Eeuo pipefail

: "${GIT_REPO_URL:?Set GIT_REPO_URL to a repository reachable from OpenShift.}"
GIT_REF="${GIT_REF:-main}"
APP_NAME="${APP_NAME:-git-workshop}"
PROJECT="${PROJECT:-git-workshop-$(whoami | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')}"
TEMPLATE="${TEMPLATE:-lab-content/openshift/template.yaml}"

command -v oc >/dev/null 2>&1 || { echo 'oc is required.' >&2; exit 1; }
oc whoami >/dev/null 2>&1 || { echo 'Authenticate with oc login first.' >&2; exit 1; }
[[ -f "${TEMPLATE}" ]] || { echo "Template not found: ${TEMPLATE}" >&2; exit 1; }

if oc get project "${PROJECT}" >/dev/null 2>&1; then
  oc project "${PROJECT}" >/dev/null
else
  oc new-project "${PROJECT}" >/dev/null
fi

oc process -f "${TEMPLATE}" \
  -p APP_NAME="${APP_NAME}" \
  -p GIT_REPO_URL="${GIT_REPO_URL}" \
  -p GIT_REF="${GIT_REF}" \
  | oc apply -f -

# A ConfigChange build should start automatically. Start one only if none exists.
if ! oc get builds -l "buildconfig=${APP_NAME}" -o name 2>/dev/null | grep -q .; then
  oc start-build "${APP_NAME}"
fi

latest_build="$(oc get builds -l "buildconfig=${APP_NAME}" --sort-by=.metadata.creationTimestamp -o name | tail -1)"
if [[ -n "${latest_build}" ]]; then
  echo "Following ${latest_build}..."
  oc logs -f "${latest_build}"
fi

oc rollout status "deployment/${APP_NAME}" --timeout=5m
route_host="$(oc get route "${APP_NAME}" -o jsonpath='{.spec.host}')"
printf '\nApplication URL: https://%s\n' "${route_host}"
printf 'Project: %s\n' "${PROJECT}"
