---
name: deprecation
description: Retire code, endpoints, fields, flags and dependencies safely, and migrate data without downtime using expand/contract. Use when removing or renaming a field, column, endpoint, event, feature flag or module, when code is suspected dead, when migrating consumers from an old interface to a new one, or when the user says "deprecate", "remove", "sunset", "clean up dead code". Execution core of the /develop deprecation branch.
---

# Deprecation and migration

Code is a liability: every line has a maintenance cost and an attack surface. Removing it is an
achievement — but only once you've **proven** nothing depends on it.

## When NOT to use

- Behavior-preserving restructuring with the same public surface — that is a refactor.
- Language or type-system migrations with no change in behavior — mechanical migration.
- Dependency vulnerability bumps.

## Process

1. **Find every consumer.** Grep across the whole repository for every spelling of the name
   (camelCase, snake_case, string literals, dynamic keys) and every source extension in play;
   check other repositories, configs, scheduled jobs, analytics/data pipelines and external
   clients. Record the evidence (`file:line` or "0 hits for <pattern>").
2. **Decide the kind of deprecation.**
   - **Advisory** (default): mark deprecated, document the replacement, stop new usage, let
     consumers migrate.
   - **Compulsory**: a removal date the consumers must meet. Requires an owner and a plan for
     each known consumer.
   **Churn rule:** whoever owns the thing being removed migrates its consumers (or funds it) —
   don't push the cost onto them.
3. **Pick the migration pattern.**
   - **Strangler** — route traffic gradually from old to new behind one entry point.
   - **Adapter** — keep the old interface as a thin shim over the new implementation.
   - **Feature flag** — switch per tenant/percentage, with an owner and an expiry date.
4. **Persisted data: expand/contract**, each step its own deployable change:
   1. **Expand** — add the new field/column/collection; old code ignores it.
   2. **Dual-write** — write both old and new; read old.
   3. **Backfill** — migrate existing records (idempotent, resumable, batched); verify counts.
   4. **Switch reads** — read new; keep writing both for a rollback window.
   5. **Contract** — stop writing old, then drop it, after the window and once consumers are at 0.
   Notify downstream data consumers at step 1 and step 5.
5. **Remove zombie code** only with step 1's evidence at zero consumers. Delete the code, its
   tests, config, flags and docs together; mention the evidence in the PR.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Nobody calls it, I checked the obvious file" | One grep in one extension is not evidence. Callers hide in other file types, strings and other repos. |
| "Rename the column in one migration, it's quicker" | Every running instance with the old code breaks mid-deploy. Expand/contract. |
| "We'll backfill later" | Reads switch, old records come back empty. Backfill before switching reads. |
| "Leave the flag, it doesn't hurt" | Every stale flag doubles the paths to test and reason about. Flags get an expiry. |
| "It might be useful someday" | That's what version control is for. |

## Red Flags

- A field/column dropped in the same change that stops writing it.
- A backfill that is not idempotent or can't resume after a crash.
- "Dead code" removed without a recorded consumer search.
- Shared or externally consumed artefacts (translations, public events, API fields) deleted by
  a code change instead of their owning process.
- A feature flag with no owner or expiry.

## Verification

- [ ] Consumer search recorded with patterns and results
- [ ] Each expand/contract step is its own deployable change, in order
- [ ] Backfill verified (counts before/after) and re-runnable
- [ ] Downstream data consumers notified (expand and contract)
- [ ] Removed code's tests, config, flags and docs removed with it
