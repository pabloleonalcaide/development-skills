# Branch: feature

New code: endpoint, use case, domain behavior. Execution core = **TDD loop, RED-first. Inomitible.**

Delegate the loop to `/tdd`. Before coding, read the repo's `.context/`:
`architecture*.md` (which layering/pattern), `testing.md` (which test level + conventions),
`good_practices.md` (the matching checklist), `styling.md` (naming, commits).

> The concrete naming and wiring of your architecture (use-case entry points, DI registration,
> layer boundaries) is **project-specific** and lives in `.context/architecture.md` — this file
> only holds the generic hexagonal shape.

## Pick the sub-type, then the RED entry point

| Sub-type | RED-first test | Then |
|----------|----------------|------|
| **Endpoint / adapter (driving)** | end-to-end test RED **before wiring anything** | wire adapter → use case → domain down to green |
| **Use case / application service** | unit test RED for the behavior (happy + each error/branch) | implement the use case to green |
| **Domain element** (value object / aggregate / domain service) | **no dedicated test** — covered black-box via the use case that exercises it | only test directly if complexity warrants (per `testing.md`) |

## Loop

1. Write the failing test at the right level. Run it — confirm RED for the right reason.
2. Minimal code to green. No more than the test demands.
3. Refactor with tests green. Apply architecture rules (layer deps, value objects over
   primitives, ports/adapters, DI registration) per `.context/architecture.md`.
4. Repeat per behavior. One behavior = one test = (ideally) one atomic commit.

## Notes

- **Runs autonomously.** Once the blueprint is approved (phase C), the RED-GREEN loop does not
  ask for confirmation on each step — RED, minimal GREEN, refactor and commit run unattended
  until a Checkpoint fires. Autonomy is governed here by `develop`, not by a mode flag in `/tdd`.
- Plan approval does **not** exempt TDD. No "build now, test later".
- Spikes belong in the scratchpad prototype (phase B), never as untested production code here.
- Register DI (repository / use case / handler) and wiring per `.context/architecture.md` — easy
  to forget, breaks at runtime.
- Then return to phase E: hardening (two axes) → gate → `/create-pr`.
