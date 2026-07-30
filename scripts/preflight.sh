#!/usr/bin/env bash
set -Eeuo pipefail

failures=0

check_command() {
  local command_name="$1"
  if command -v "${command_name}" >/dev/null 2>&1; then
    printf '[OK] %-12s %s\n' "${command_name}" "$(${command_name} version --client 2>/dev/null | head -1 || ${command_name} --version 2>/dev/null | head -1 || true)"
  else
    printf '[FAIL] Missing required command: %s\n' "${command_name}" >&2
    failures=$((failures + 1))
  fi
}

check_command git
check_command oc
check_command curl

if command -v node >/dev/null 2>&1; then
  printf '[OK] node         %s\n' "$(node --version)"
else
  printf '[INFO] node is optional; local application testing will be skipped.\n'
fi

if git config --global user.name >/dev/null 2>&1; then
  printf '[OK] Git user.name: %s\n' "$(git config --global user.name)"
else
  printf '[WARN] Configure Git user.name before committing.\n'
fi

if git config --global user.email >/dev/null 2>&1; then
  printf '[OK] Git user.email: %s\n' "$(git config --global user.email)"
else
  printf '[WARN] Configure Git user.email before committing.\n'
fi

if oc whoami >/dev/null 2>&1; then
  printf '[OK] OpenShift user: %s\n' "$(oc whoami)"
else
  printf '[WARN] Not currently authenticated to OpenShift.\n'
fi

if (( failures > 0 )); then
  exit 1
fi

printf '\nPreflight completed.\n'
