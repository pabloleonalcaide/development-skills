# Testing

> Template. State how tests work in this repo so `tdd` and `diagnose` pick the right level.

## Test levels
- **unit** — a use case or domain element in isolation. Where: `...`. Runner: `...`.
- **integration** — a use case against real adapters (db, etc.). Where: `...`.
- **e2e** — a driving adapter end to end (http endpoint, CLI). Where: `...`.

## What a good test looks like
- Asserts **behavior**, not implementation. No assertions on private state or call counts unless
  the behavior *is* the interaction.
- One behavior per test. Arrange–act–assert.
- No loose assertions (`expect.any`, `toBeTruthy` where a real value is known).
- Domain elements are covered black-box via the use case that exercises them, unless complexity
  warrants a dedicated test.

## Commands
- Run unit: `...`
- Run all + typecheck/lint (the verification gate): `...`
