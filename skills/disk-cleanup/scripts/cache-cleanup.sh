#!/usr/bin/env bash
#
# cache-cleanup.sh — delete build/package caches that regenerate on their own.
#
# Usage (run from inside the repo to include its caches):
#   cache-cleanup.sh [--plan]    Show sizes (default)
#   cache-cleanup.sh --execute   Delete them
#
# Targets:
#   repo:   <repo>/.turbo/cache            (Turborepo local cache → next build is slower)
#           **/node_modules/.vite          (Vite dep pre-bundle → next dev start is slower)
#   global: ~/.yarn/berry/cache            (Yarn Berry global cache → re-downloaded on demand)
#           ~/.npm/_cacache                (npm cache → re-downloaded on demand)
# A repo cache is skipped while a process that uses it (vite / turbo) is running.

set -euo pipefail
MODE="${1:---plan}"

REPO="$(git rev-parse --show-toplevel 2>/dev/null || true)"
declare -a TARGETS=()

running() { pgrep -f "$1" >/dev/null 2>&1; }

if [ -n "$REPO" ]; then
  if running "turbo"; then echo "skip: $REPO/.turbo/cache (turbo is running)"
  elif [ -d "$REPO/.turbo/cache" ]; then TARGETS+=("$REPO/.turbo/cache"); fi

  if running "vite"; then echo "skip: node_modules/.vite caches (a vite process is running)"
  else
    while IFS= read -r d; do TARGETS+=("$d"); done < <(
      find "$REPO" -maxdepth 5 -type d -path '*/node_modules/.vite' -prune 2>/dev/null)
  fi
else
  echo "(not inside a git repo: only global caches)"
fi

for d in "$HOME/.yarn/berry/cache" "$HOME/.npm/_cacache"; do
  [ -d "$d" ] && TARGETS+=("$d")
done

if [ ${#TARGETS[@]} -eq 0 ]; then echo "No caches found."; exit 0; fi

echo "Plan:"
for d in "${TARGETS[@]}"; do printf "  %8s  %s\n" "$(du -sh "$d" 2>/dev/null | cut -f1)" "$d"; done
echo

if [ "$MODE" != "--execute" ]; then
  echo "(plan only — nothing deleted. Re-run with --execute to apply.)"
  exit 0
fi

for d in "${TARGETS[@]}"; do
  case "$d" in
    */.turbo/cache|*/node_modules/.vite|"$HOME/.yarn/berry/cache"|"$HOME/.npm/_cacache") rm -rf "$d"; echo "deleted $d" ;;
    *) echo "refusing unexpected path: $d" >&2 ;;
  esac
done
