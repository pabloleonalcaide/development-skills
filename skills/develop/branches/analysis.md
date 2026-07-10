# Branch: analysis

Audit / investigation, no production code. Exit = **verified findings report, no PR.**

## Loop

1. **Discovery** (phase A) at full depth — parallel `Explore`/`Plan` by subsystem.
   Greps cover `.ts/.tsx/.js/.jsx`.
2. **Gather findings**, each with concrete evidence (`file:line`). No claim without a location.
3. **Adversarial verification (the exit gate).** For each material finding, spawn a fresh
   subagent prompted to **refute** it. A finding enters the report as *fact* only if it
   survives. What can't be verified is marked **hypothesis**, not conclusion.
4. **Write the report** (`ANALYSIS.md` template): context · findings (with evidence) · risks ·
   **actionable recommendation** (not just description).
5. **Hook back to the router** if work emerges: "these tasks fall out → `/to-tickets`?".

## Where it goes

- Born from a tracker task → post the report there (comment/doc).
- Loose exploration → keep in scratchpad; you decide whether to upload.
- Never a PR.
