---
name: clean-worktrees
description: Clean up git worktrees on the local machine — remove worktrees that are clean and fully merged, delete their merged branches, and skip anything with pending work. Use when the user wants to clean, remove, prune, or tidy up git worktrees, mentions "limpia los worktrees", "elimina worktrees", "clean up worktrees", or asks to get rid of leftover worktree directories.
---

# Clean Worktrees

Safely removes throwaway git worktrees from the local repo. Only touches worktrees that
are **clean and fully integrated**; anything with uncommitted changes, unmerged commits,
a detached HEAD, or a lock is skipped and reported so the user decides manually. Always
shows a plan and gets confirmation before deleting.

## Workflow

1. **Analyse (dry run).** Run from inside the target repo (the script is global, so use
   its absolute path):
   ```bash
   ~/.claude/skills/clean-worktrees/scripts/worktree-cleanup.sh --plan
   ```
   The script auto-detects the repo from the current working directory.

2. **Present the plan** to the user in Spanish, in the script's three groups: SAFE (removed
   by `--execute`), REMOVABLE (open/closed PR or no PR, but clean and pushed — offer each one
   individually) and SKIP, each with its reason. Do not paraphrase away the reasons — the
   user needs them to decide.

3. **Confirm.** Ask for an explicit OK before deleting. If the user only wants a subset,
   use `worktree-cleanup.sh --remove <path>` per item rather than `--execute`, which acts on
   all SAFE entries.

4. **Execute** once confirmed:
   ```bash
   ~/.claude/skills/clean-worktrees/scripts/worktree-cleanup.sh --execute
   ```

5. **Report** what was removed and what remains.

## Rules (baked into the script)

- The **main worktree is never touched**.
- The script delegates to the sibling `disk-cleanup` skill's `scripts/worktree-cleanup.sh`
  (canonical copy; disk-cleanup covers Docker and caches too).
- It runs `git fetch` and compares against `origin/<default>`, never the local default branch.
- SAFE = not main, not locked, not detached, clean, and either contained in `origin/<default>`
  or its PR is MERGED (squash) with the branch tip equal to `origin/<branch>`.
- REMOVABLE = clean and pushed but PR open/closed/absent: no code is lost, but ask first.
- Branches are deleted with `git branch -d` only (never `-D`) — an unmerged branch is
  kept even if its worktree was removed.
- After removal it runs `git worktree prune` to clear stale references.

## Agent rules (not enforced by the script)

- Never run `rm -rf` or `git worktree remove --force` yourself — permissions and the
  auto-mode classifier block both. When a directory survives removal ("Directory not
  empty") or a worktree needs a forced removal, list the exact command and ask the user to
  run it with `! <command>`; then re-run `--plan` to confirm.
- Before executing, state per worktree whether its local branch will be deleted, as the
  script's plan reports it — never from memory.

## Manual commands (for a subset or edge cases)

```bash
git worktree list                      # inspect
worktree-cleanup.sh --remove <path>    # remove one, only if clean and pushed
git worktree remove --force <path>     # user-only (`! …`): remove one WITH pending changes (data loss)
git worktree unlock <path>             # unlock a locked worktree first
git branch -d <branch>                 # delete its merged branch
```
