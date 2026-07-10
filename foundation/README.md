# foundation — the engineering baseline

This is the **loaded, opinionated knowledge base** the skills assume: how to build software with
DDD, hexagonal architecture and strict TDD. It is **not** a set of empty templates — it's a base
you copy into a repo and **extend**.

## How to use it

Copy the contents of `foundation/` into your repo's `.context/`:

```bash
cp -R foundation/ <your-repo>/.context/
```

Then **fill the repo-specific slots** the skills also need but that can't be generic:
- the exact test / build / lint commands (in `testing.md` and `styling.md`)
- your concrete naming, layering and DI wiring (extend `architecture.md` and `patterns/`)
- your branch-naming and PR rules (in `styling.md`)

The skills read `.context/`; they hardcode nothing. Empty slots degrade gracefully — a skill will
say what's missing and ask rather than invent.

## Two levels

- **Core** (the files at the root: `architecture.md`, `good_practices.md`, `testing.md`,
  `styling.md`) — the **non-negotiable doctrine**. Universal to any DDD/hexagonal/TDD codebase.
  These are the files the skills read directly (`develop` reads `.context/testing.md`, etc.).
- **Catalogue** (`patterns/`) — **opinionated conventions**: one concrete way to solve a recurring
  problem. Strong defaults, taken à la carte. "This is how we do it," not "this is the only way."
  Grow this folder over time; it's meant to be extended.

The line matters: *"the domain must not depend on infrastructure"* (core, a law) and *"queries
carry a context prefix on a shared bus"* (catalogue, a choice) should not be read with the same
authority.

## Credit

Distilled from a production DDD/hexagonal/TDD codebase, generalized to be product- and
stack-agnostic. See the repo's [PHILOSOPHY.md](../PHILOSOPHY.md).
