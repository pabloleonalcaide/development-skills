#!/usr/bin/env bash
#
# worktree-cleanup.sh — classify and clean up git worktrees.
#
# Usage (run from inside the repo):
#   worktree-cleanup.sh [--plan]        Analyse and print the plan (default; deletes nothing)
#   worktree-cleanup.sh --execute       Remove every SAFE worktree (+ its branch if git -d allows)
#   worktree-cleanup.sh --remove <path> Remove ONE worktree if it is clean and fully pushed
#                                       (used right after opening a PR from it)
#
# A worktree is SAFE to remove only when it is:
#   - not the main worktree, not locked, not detached
#   - clean (no uncommitted or untracked changes)
#   - integrated: no commits missing from origin/<default>, OR its PR is MERGED on GitHub
#     (squash merges leave the original commits outside the default branch) and the local
#     branch tip equals origin/<branch>
#
# Worktrees whose PR is still OPEN but are clean and pushed are reported as REMOVABLE:
# no code is lost (the branch stays local and on origin), but you may still be working there.
# Branches are deleted with `git branch -d` only (never -D).

set -euo pipefail

MODE="${1:---plan}"
TARGET="${2:-}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git repository." >&2
  exit 1
fi

git fetch --quiet --prune origin 2>/dev/null || echo "(warning: git fetch failed — using cached remote refs)" >&2

default_branch() {
  local ref
  if ref=$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null); then
    echo "${ref#refs/remotes/origin/}"; return
  fi
  for b in main master; do
    if git show-ref --verify --quiet "refs/remotes/origin/$b"; then echo "$b"; return; fi
  done
  git rev-parse --abbrev-ref HEAD
}

DEFAULT_BRANCH="$(default_branch)"
BASE_REF="origin/$DEFAULT_BRANCH"
git show-ref --verify --quiet "refs/remotes/$BASE_REF" || BASE_REF="$DEFAULT_BRANCH"
HAS_GH=0; command -v gh >/dev/null 2>&1 && HAS_GH=1

# Prints "<number> <STATE>" of the most recent PR whose head is the branch, or nothing.
pr_state() {
  [ $HAS_GH -eq 1 ] || return 0
  gh pr list --head "$1" --state all --limit 1 --json number,state \
    --jq '.[0] | select(.) | "\(.number) \(.state)"' 2>/dev/null || true
}

# 0 when the local branch tip is exactly origin/<branch>.
is_pushed() {
  local local_sha remote_sha
  local_sha="$(git rev-parse --verify --quiet "refs/heads/$1")" || return 1
  remote_sha="$(git rev-parse --verify --quiet "refs/remotes/origin/$1")" || return 1
  [ "$local_sha" = "$remote_sha" ]
}

# Sets CLASS (SAFE | REMOVABLE | SKIP) and REASON for one worktree.
classify() {
  local path="$1" branch="$2" detached="$3" locked="$4"
  CLASS="SKIP"; REASON=""
  if [ -n "$locked" ]; then REASON="locked (git worktree unlock '$path' if it is really unused)"; return; fi
  if [ -n "$detached" ]; then REASON="detached HEAD — no branch to reason about"; return; fi
  if [ -n "$(git -C "$path" status --porcelain 2>/dev/null)" ]; then REASON="has uncommitted changes"; return; fi

  if [ -z "$(git log --oneline "${BASE_REF}..refs/heads/${branch}" 2>/dev/null | head -n1)" ]; then
    CLASS="SAFE"; REASON="fully contained in $BASE_REF"; return
  fi

  local pr; pr="$(pr_state "$branch")"
  if ! is_pushed "$branch"; then REASON="commits not in $BASE_REF and not pushed to origin/$branch"; return; fi
  case "$pr" in
    *" MERGED") CLASS="SAFE"; REASON="PR #${pr%% *} merged (squash), branch pushed" ;;
    *" OPEN")   CLASS="REMOVABLE"; REASON="PR #${pr%% *} open — clean and pushed, no code lost" ;;
    *" CLOSED") CLASS="REMOVABLE"; REASON="PR #${pr%% *} closed unmerged — clean and pushed" ;;
    *)          CLASS="REMOVABLE"; REASON="no PR found — clean and pushed to origin/$branch" ;;
  esac
}

MAIN_WT=""
declare -a PATHS=() BRANCHES=() CLASSES=() REASONS=()
cur_path="" cur_branch="" cur_detached="" cur_locked=""
flush() {
  [ -z "$cur_path" ] && return
  if [ -z "$MAIN_WT" ]; then
    MAIN_WT="$cur_path"
  else
    local b="${cur_branch#refs/heads/}"
    classify "$cur_path" "$b" "$cur_detached" "$cur_locked"
    PATHS+=("$cur_path"); BRANCHES+=("$b"); CLASSES+=("$CLASS"); REASONS+=("$REASON")
  fi
  cur_path="" cur_branch="" cur_detached="" cur_locked=""
}
while IFS= read -r line; do
  case "$line" in
    "worktree "*) flush; cur_path="${line#worktree }" ;;
    "branch "*)   cur_branch="${line#branch }" ;;
    "detached")   cur_detached=1 ;;
    "locked"*)    cur_locked=1 ;;
  esac
done < <(git worktree list --porcelain)
flush

remove_one() {
  local path="$1" branch="$2"
  echo "→ git worktree remove '$path'"
  git -C "$MAIN_WT" worktree remove "$path"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    if git -C "$MAIN_WT" branch -d "$branch" >/dev/null 2>&1; then
      echo "  deleted branch $branch"
    else
      echo "  kept branch $branch (git branch -d refuses: not merged locally — normal after a squash merge)"
    fi
  fi
}

if [ "$MODE" = "--remove" ]; then
  [ -n "$TARGET" ] || { echo "Usage: $0 --remove <worktree-path>" >&2; exit 2; }
  target="$(cd "$TARGET" 2>/dev/null && pwd -P || echo "$TARGET")"
  [ "$target" = "$(cd "$MAIN_WT" && pwd -P)" ] && { echo "Refusing: '$TARGET' is the main worktree." >&2; exit 1; }
  for i in "${!PATHS[@]}"; do
    [ "$(cd "${PATHS[$i]}" 2>/dev/null && pwd -P)" = "$target" ] || continue
    if [ "${CLASSES[$i]}" = "SKIP" ]; then
      echo "Not removed: ${PATHS[$i]} — ${REASONS[$i]}" >&2; exit 1
    fi
    remove_one "${PATHS[$i]}" "${BRANCHES[$i]}"
    git -C "$MAIN_WT" worktree prune
    echo "Main worktree: $MAIN_WT"
    exit 0
  done
  echo "Not a worktree of this repo: $TARGET" >&2; exit 1
fi

echo "Compared against: $BASE_REF$([ $HAS_GH -eq 1 ] || echo '  (gh not found: squash merges not detected)')"
echo "Main worktree (never touched): $MAIN_WT"
for cls in SAFE REMOVABLE SKIP; do
  echo; n=0
  for i in "${!PATHS[@]}"; do [ "${CLASSES[$i]}" = "$cls" ] && n=$((n+1)); done
  case "$cls" in
    SAFE)      echo "SAFE to remove ($n) — removed by --execute:" ;;
    REMOVABLE) echo "REMOVABLE on request ($n) — not touched by --execute, use --remove <path>:" ;;
    SKIP)      echo "SKIP ($n):" ;;
  esac
  [ $n -eq 0 ] && echo "  (none)"
  for i in "${!PATHS[@]}"; do
    [ "${CLASSES[$i]}" = "$cls" ] && echo "  - ${PATHS[$i]}  [${BRANCHES[$i]}]  — ${REASONS[$i]}"
  done
done
echo

if [ "$MODE" != "--execute" ]; then
  echo "(plan only — nothing deleted. Re-run with --execute to apply.)"
  exit 0
fi

removed=0
for i in "${!PATHS[@]}"; do
  [ "${CLASSES[$i]}" = "SAFE" ] || continue
  remove_one "${PATHS[$i]}" "${BRANCHES[$i]}"; removed=$((removed+1))
done
git worktree prune
echo "Done. Removed $removed worktree(s)."
