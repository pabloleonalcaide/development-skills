---
name: disk-cleanup
description: Reclaim local disk space safely on a development machine — leftover git worktrees, Docker leftovers from integration tests (Testcontainers containers, orphan anonymous volumes, dangling images, build cache) and regenerable caches (Turborepo, Vite, Yarn Berry global, npm). Use when the disk is full or nearly full, on ENOSPC / "no space left on device" errors, when Docker Desktop hangs or won't open, when a SessionStart warning reports low free space, or when the user says "libera espacio", "limpia el disco", "disk cleanup", "free up space".
---

# Disk cleanup

Free space by deleting only what can be regenerated or is already safe elsewhere: a report and
a plan first, an explicit OK from the user, then execution. Never touch a container's data, a
named volume, uncommitted work or an unpushed commit.

## When NOT to use

- Only stale worktrees to tidy, no space pressure → `/clean-worktrees` (same script, narrower).
- Removing the worktree a PR was just opened from → `/create-pr` does that itself.
- Docker data the user wants gone on purpose (reset a database, drop a named volume) — that is a
  deliberate, targeted command, not a cleanup sweep.

## Process

All scripts live in `scripts/` next to this file; run them from inside the repo.

1. **Unblock if the disk is at 0.** With no free space even command output fails (`ENOSPC`).
   Measure with a read-only `df -h "$HOME"` and start with the biggest safe win (usually worktrees,
   ~30 GB each with their `node_modules`). Docker cannot start on a full disk: free space first.
2. **Report.** Run `scripts/disk-report.sh`. It prints free space and the `--plan` of the three
   cleaners; nothing is deleted. Sizes of worktrees: `du -sh <path>` (slow — run in background).
3. **Present the plan** to the user in their language, per area: what goes, how much it frees,
   what is kept and **why** (copy the script's reasons, don't paraphrase them away). REMOVABLE
   worktrees (open PR, clean, pushed) are offered one by one, never bundled into "all".
4. **Confirm.** Explicit OK per area. A subset → run per item (`worktree-cleanup.sh --remove
   <path>`), not `--execute`.
5. **Execute** the confirmed areas:
   - worktrees: `scripts/worktree-cleanup.sh --execute` (SAFE ones) / `--remove <path>`
     Before running, state per worktree whether its local branch will be deleted, as the
     `--plan` reports it — never from memory. A directory that survives removal ("Directory
     not empty") or a worktree that needs `--force` → give the user the exact command to run
     as `! <command>`, then re-run `--plan`. Never run `rm -rf` or `--force` yourself.
   - Docker: `scripts/docker-cleanup.sh --execute` (needs the daemon up)
   - caches: `scripts/cache-cleanup.sh --execute` (stop dev servers first; it skips caches in use)
   Long removals (worktrees) go to the background; report when they finish.
6. **Report** freed space (`df -h` before/after) and what was kept.

Docker Desktop hung (UI won't open) → restart it without losing containers: free space, `osascript
-e 'quit app "Docker"'`, wait; if the backend ignores it, SIGTERM `com.docker.backend`; SIGKILL only
once no `com.docker.virtualization`/`krun` process is left (the VM is down, data is closed). Then
`open -a Docker` and check `docker ps -a`. Never "Reset to factory defaults" / "Clean / Purge data".

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The script says commits not in master, so it's unmerged" | Squash merges leave the original commits out of master; check the PR state and whether the tip is pushed. |
| "`docker system prune -a --volumes` frees the most" | It also deletes named volumes and stopped stack containers: local databases gone. |
| "The worktree is clean, its open PR doesn't matter" | No code is lost, but the user may still be working there — offer it, don't assume. |
| "Deleting the cache while the dev server runs is fine" | A running Vite/Turbo loses its cache mid-flight; stop it or let the script skip it. |

## Red Flags

- `docker system prune`, `docker volume prune -a` or `--volumes` in a command.
- The agent itself running `rm -rf` or `git worktree remove --force` (the user runs them).
- `git branch -D` without the user naming that exact item.
- Deleting before the user saw the plan, or executing "all" when they picked a subset.
- Reporting "freed X GB" without a `df -h` after.

## Verification

- [ ] `disk-report.sh` (or each `--plan`) output shown before deleting anything
- [ ] user's OK recorded per area / per REMOVABLE worktree
- [ ] `df -h` after, with the freed amount
- [ ] `docker ps -a` still lists the stack containers (if Docker was touched)
- [ ] kept items listed with their reason
