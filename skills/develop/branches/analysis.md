# Branch: analysis

Audit / investigation, no production code. Exit = **verified findings report, no PR.**

## Loop

1. **Discovery** (phase A) at full depth — parallel `Explore`/`Plan` by subsystem.
   Greps cover every source extension in play (a single-extension sweep hides callers).
2. **Gather findings**, each with concrete evidence (`file:line`). No claim without a location.
3. **Blind adversarial verification (the exit gate).** For each material finding, spawn a
   fresh `general-purpose` subagent and pass it **the artifact and a neutral question — never
   the claim**. Not "there is an N+1 at `X.ts:40`", but "here is `X.ts:30-60`; how many queries
   does it issue per element, and under which inputs?". Told the conclusion, a verifier anchors:
   it confirms, or contradicts for the sake of it.
   - It reaches the same conclusion independently → **✅ verified**.
   - It reaches a different one → reconcile against the code yourself; if still unresolved,
     **⚠️ hypothesis**, never a conclusion.
   - At most **3 cycles** per finding. **Doubt theater** red flag: several cycles with
     substantive objections and none classified as actionable — stop and report it as
     unresolved.
4. **Write the report** (`ANALYSIS.md` template): context · findings (with evidence) · risks ·
   **actionable recommendation** (not just description).
5. **Hook back to the router** if work emerges: "these tasks fall out → `/to-tickets`?".

## Where it goes

- Born from a tracker task → post the report there (comment/doc).
- Loose exploration → keep in scratchpad; you decide whether to upload.
- Never a PR.
