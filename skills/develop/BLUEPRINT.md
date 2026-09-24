# Blueprint — <desc>

> Single human approval gate. Produced in plan mode (phase C). Lives in the scratchpad, linked
> from the tracker task — not in the repo tree.

## Context
What and why, in one short paragraph. Link the tracker task / source.

## Branch
feature | bugfix | refactor | analysis  — and one line on why.

## Decisions
The resolved decision tree from the alignment grilling (scope, needs, trade-offs). Bullet each call made.
Flag the **hard** ones (⚑ — hard to reverse, surprising without context, a real trade-off) and
keep their reasoning: it travels to the tracker task.

## Steps
Numbered, ordered by dependency. Each step small enough to be one atomic commit.

## Files
| File | Action (new/edit/delete) | Why |
|------|--------------------------|-----|

## Seams under test
The public interfaces through which each behavior is observed (endpoint, use case, rendered
page…). Prefer existing seams and the highest level that reaches the behavior. Mark any **new**
seam and point to the decision in B that introduced it — ideally there are none.

| Behavior | Seam | New? |
|----------|------|------|

## Visual impact
**yes / no.** If yes → browser confirmation is a hard checkpoint before `/create-pr`.

## Data impact
**yes / no.** Does the change alter the shape of persisted data (added / renamed / retyped /
deleted fields; backfill or not)? If yes → a notice to the downstream data consumers is a hard
checkpoint.

## Verification
The repo's CI commands to run, in order (discovered, not assumed). Test levels touched.

## Out of scope
Anything deliberately excluded / to be split into separate tasks.
