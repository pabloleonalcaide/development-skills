# Branch: bugfix

Something is broken / regressed. Execution core = `/diagnose` + **regression test in RED first**.

## Loop

1. **Enter `/diagnose`** — reproduce the bug deterministically before theorizing.
2. **Root-cause before any guard.** Open the file where the effect actually lives. Defensive
   guards without a root cause are wasted commits. Don't blame a refactor
   without opening the code that produces the effect.
3. **Write the regression test RED — blind to the fix.** Delegate it to a fresh
   `general-purpose` subagent given only the **symptom** (observed vs expected), the **seam**
   named in the blueprint and the repo's `testing.md` — not the hypothesis, not the fix. A test
   written by whoever already knows the fix tends to test the fix, not the bug. Then you check
   it: right level (unit / integration / e2e per `testing.md`), the highest seam that reaches
   the bug, and it **fails for the real reason**. Print the RED summary and continue — don't
   wait for a reply.
4. **Minimal fix** — the simplest change that turns it green. Nothing extra.
5. **Verify** the whole gate (the bug's level + the surrounding suite) stays green.

## Notes

- The regression test is the proof the bug existed and is gone — it is **not** optional.
- If the fix reveals unrelated breakage, that's a scope signal → Checkpoints (note aside / separate branch).
- Then return to phase E: hardening → gate → `/create-pr`.
