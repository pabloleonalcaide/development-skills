#!/usr/bin/env bash
#
# disk-report.sh — read-only overview of free space and of what each cleanup would reclaim.
# Run from inside the repo. Deletes nothing.

set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "######## Free space"
df -h "$HOME" | tail -1 | awk '{print "  free: " $4 " of " $2 " (" $5 " used)"}'
echo

echo "######## Worktrees"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  "$DIR/worktree-cleanup.sh" --plan
else
  echo "  (not inside a git repo — skipped)"
fi
echo

echo "######## Docker"
"$DIR/docker-cleanup.sh" --plan || true
echo

echo "######## Caches"
"$DIR/cache-cleanup.sh" --plan
