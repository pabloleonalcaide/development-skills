# PR explainer — the page every PR links to

> Built in phase E, step **Explain**, after the verification gate and before `/create-pr`.
> Every non-analysis PR gets one. The PR body stays short (what/why as a summary) and links here
> — or embeds it — for the full picture. Authorized by the approved blueprint — not a checkpoint.

## Who it is for

A reviewer with **no context**: they have not read the blueprint, the grilling or the agent
session. Write so they understand the problem and can judge the solution in five minutes.

## Sources — and only these

- The approved blueprint (Context, Decisions with ⚑, Seams under test, Out of scope).
- The tracker task (the subtask the PR links).
- The **frozen final diff** (`git diff <base>...HEAD`) and the gate result.
- Screenshots taken at Checkpoint 1.

Nothing from agent memory or personal notes: what isn't in those sources doesn't go in.

## Content (in the PR's language)

1. **Problem** — in plain words: what was wrong or missing, who it affects, how it showed up.
   From the ticket and the blueprint's Context, not from the code.
2. **Chosen solution** — what was done and where, by concept (use case, endpoint, page), not a
   file list.
3. **Decisions** — the ⚑ decisions with their reasoning, and the **alternatives discarded** and
   why. Omit the section if the blueprint had no real trade-off.
4. **Before / after** — only when there is something to see: screenshots when visual impact was
   declared, a small diagram when a flow, state machine or data shape changes. Otherwise omit.
5. **How to verify** — steps a reviewer can follow, and which behaviors the tests cover (the
   seams). If part of the gate was skipped, say so here too.
6. **Deviations and risks** — same content as the closing's Deviations / Risks. Empty → omit.

Keep it short: an empty section is dropped, never filled with "N/A".

## Screenshots

Taken during **Checkpoint 1** (browser confirmation), *before* and *after* the change when the
before state is reachable (the base branch or a toggle), saved as files outside the repo tree
(scratchpad / temp dir). A tool that only shows the image to the agent is not enough: it must
exist on disk to be published. If no tool can save it, say so in the closing — never describe a
screenshot that doesn't exist.

## Publishing — depends on the harness

- **Harness can publish a rich page** (e.g. Claude Code Artifacts): build an HTML page with the
  sections above and the screenshots, publish it with the harness's own tool, and pass the URL to
  `/create-pr`. If the page is private by default, the closing reminds the user to share it with
  the reviewers.
- **Otherwise (default)**: render sections 1–6 as markdown and pass them to `/create-pr`, which
  appends them to the PR body inside `<details><summary>Full explanation</summary>…</details>`.
  `gh`/`glab` can't upload images: list the screenshot paths in the closing so the user can drag
  them into the PR.

Either way, the closing says which path ran.
