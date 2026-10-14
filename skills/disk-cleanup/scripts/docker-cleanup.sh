#!/usr/bin/env bash
#
# docker-cleanup.sh — reclaim Docker space without touching your stack's data.
#
# Usage:
#   docker-cleanup.sh [--plan]    Show what would be removed (default)
#   docker-cleanup.sh --execute   Remove it
#
# Removes ONLY regenerable leftovers:
#   - stopped Testcontainers containers (label org.testcontainers=true); running ones are
#     listed but kept, they may belong to a test run in progress
#   - anonymous volumes not used by any container (`docker volume prune` without -a)
#   - dangling images (untagged layers) and the build cache
# Never runs `docker system prune`, never removes named volumes, tagged images or
# containers that are not Testcontainers'.

set -euo pipefail
MODE="${1:---plan}"

if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon not reachable — start Docker first (with free disk space)." >&2
  exit 1
fi

echo "== docker system df (before)"
docker system df
echo

stopped_tc="$(docker ps -aq --filter label=org.testcontainers=true --filter status=exited --filter status=created --filter status=dead)"
running_tc="$(docker ps -q --filter label=org.testcontainers=true)"
anon_vols="$(docker volume ls -q --filter dangling=true | grep -E '^[0-9a-f]{64}$' || true)"
dangling_imgs="$(docker images -q --filter dangling=true)"

count() { [ -z "$1" ] && echo 0 || echo "$1" | wc -l | tr -d ' '; }
echo "Plan:"
echo "  - stopped Testcontainers containers: $(count "$stopped_tc")"
echo "  - running Testcontainers containers (kept): $(count "$running_tc")"
echo "  - unused anonymous volumes: $(count "$anon_vols")"
echo "  - dangling images: $(count "$dangling_imgs")"
echo "  - build cache: all of it (see 'Build Cache' above)"
echo

if [ "$MODE" != "--execute" ]; then
  echo "(plan only — nothing deleted. Re-run with --execute to apply.)"
  exit 0
fi

[ -n "$stopped_tc" ] && docker rm -v $stopped_tc >/dev/null && echo "removed stopped Testcontainers containers"
docker volume prune -f >/dev/null && echo "pruned unused anonymous volumes"
docker image prune -f >/dev/null && echo "pruned dangling images"
docker builder prune -f >/dev/null && echo "pruned build cache"
echo
echo "== docker system df (after)"
docker system df
echo "Note: Docker Desktop returns freed space to macOS gradually (Docker.raw shrinks over time)."
