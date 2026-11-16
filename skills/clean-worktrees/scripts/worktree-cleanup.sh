#!/usr/bin/env bash
# Delegates to the canonical script in the sibling disk-cleanup skill (single source of truth).
exec "$(cd "$(dirname "$0")/../../disk-cleanup/scripts" && pwd)/worktree-cleanup.sh" "$@"
