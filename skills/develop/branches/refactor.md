# Branch: refactor

Behavior-preserving change. Execution core = **existing tests are the contract.**

## Loop

1. **Run the existing suite green first.** If the area has no coverage, you're flying blind:
   stop and add characterization tests (capturing current behavior) **before** touching code.
   Flag this — it's a real gap, not part of the refactor's scope.
2. Refactor in small steps, re-running tests after each. They must stay green throughout.
3. **No new behavior, no new tests** for new behavior — if you're adding behavior, it's not a
   refactor anymore (scope signal → Checkpoints, split it out).
4. Apply architecture/style rules from `.context/` (layer deps, naming, biome).

## Notes

- A refactor that changes a test's *expectations* is not behavior-preserving — re-examine.
- Keep it strictly in scope: never "improve" unrelated code along the way (repo rule).
- Then return to phase E: hardening → gate → `/create-pr`.
