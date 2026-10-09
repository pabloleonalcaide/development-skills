---
name: create-pr
description: Commit the current branch, push it, and open a pull request. Use at the delivery step of a development task, once the work is done and verified. Triggered by "open a PR", "ship this", "create the pull request", or as the delivery step of /develop.
---

# create-pr

Ship the finished work as a pull request. The branch already exists (created in `develop` phase D). Keep the PR small and readable; the full detail lives in the tracker task.

## Steps

1. **Confirm the branch and diff.** `git status` + `git diff <base>...HEAD`. Never open a PR from the main branch.
2. **Commit** any pending work in atomic commits with clear messages (follow `.context/styling.md` if present). Never silence `git commit` output: a failing pre-commit hook aborts the commit and its error is the only signal. After each commit, check the exit code and that `git log -1 --oneline` shows it; if a hook reformatted files, re-stage and commit again before pushing.
3. **Push** the branch: `git push -u origin HEAD`.
4. **Open the PR** with the tracker's CLI — `gh pr create` for GitHub, `glab mr create` for GitLab (see `docs/agents/issue-tracker.md`):
   - **Title**: what the change does, imperative mood.
   - **Body**: what / why + a link to the tracker task. Keep it short — detail lives in the task. If that task has subtasks, link the subtask this change implements, never the parent; ask if it's ambiguous.
   - **Reviewers / labels / CI**: apply whatever your repo documents in `.context/`. This skill hardcodes none.
5. **Report** the PR URL.

## Notes

- This is the **generic** delivery skill. Anything repo-specific — required reviewers, CI gates, a PR template, protected-branch rules, a branch-naming convention — belongs in your repo's `.context/`, not here.
- **Non-analysis branches only.** An `analysis` task produces a report, not a PR.
