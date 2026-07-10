# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`.context/glossary.md`** — the canonical vocabulary of this context.
- **`.context/decisions/`** — read the decision records that touch the area you're about to work in.

In a multi-context repo, each context keeps its own `.context/` (e.g. `apps/<context>/.context/glossary.md` and `apps/<context>/.context/decisions/`). Read the one relevant to the topic; if a root-level `.context/` also exists, treat it as the system-wide context.

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront. The producer skill (`/domain-modeling`) creates them lazily when terms or decisions actually get resolved.

## File structure

Single-context repo (most repos):

```
/
├── .context/
│   ├── glossary.md
│   └── decisions/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

Multi-context repo (a monorepo with separate contexts):

```
/
├── .context/decisions/                ← system-wide decisions (optional)
└── apps/
    ├── ordering/.context/
    │   ├── glossary.md
    │   └── decisions/                     ← context-specific decisions
    └── billing/.context/
        ├── glossary.md
        └── decisions/
```

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `.context/glossary.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag decision conflicts

If your output contradicts an existing decision record, surface it explicitly rather than silently overriding:

> _Contradicts decision 0007 (event-sourced orders) — but worth reopening because…_
