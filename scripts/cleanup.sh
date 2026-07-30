#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT="${PROJECT:-}"
if [[ -z "${PROJECT}" ]]; then
  echo 'Set PROJECT to the workshop project that should be deleted.' >&2
  exit 1
fi

case "${PROJECT}" in
  git-workshop-*) ;;
  *)
    echo "Refusing to delete project '${PROJECT}'. Expected a name beginning with git-workshop-." >&2
    exit 1
    ;;
esac

oc get project "${PROJECT}" >/dev/null 2>&1 || {
  echo "Project '${PROJECT}' does not exist."
  exit 0
}

oc delete project "${PROJECT}"
