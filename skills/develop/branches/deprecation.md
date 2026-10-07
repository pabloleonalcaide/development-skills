# Branch: deprecation

Remove, rename or migrate away from code, fields, endpoints, events, flags or modules.
Execution core = **`/deprecation`**: prove the consumers, then remove or migrate in safe steps.

## Loop

1. **Consumer search first** (phase A at full depth), per `/deprecation` step 1. Record patterns
   and hits in the blueprint — this evidence is the branch's contract, like existing tests are
   for a refactor.
2. **Pick the shape in the blueprint:**
   - consumers at **0** → straight removal (code + tests + config + flags + docs together);
   - consumers **> 0** or persisted data involved → **expand/contract**: this task is *one* step
     of it, declared in the blueprint; later steps become tracker tasks (`/to-tickets`).
3. **Characterization before removal.** If removing a path changes what a still-living caller
   sees, pin that caller's behavior with a test first (RED is not required — it is a guard).
4. **Remove / migrate** in small atomic commits; the suite stays green after each.
5. **Data impact** (dual-write, backfill, drop) → Checkpoint 4 notice, stating which
   expand/contract step this is.

## Notes

- Shared artefacts owned by another process (translations, public contracts, external events)
  are removed through that process, never by a code change — note them under Pending.
- Then return to phase E: hardening → gate → `/create-pr`. The PR body cites the consumer
  search evidence.
