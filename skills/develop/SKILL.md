---
name: develop
description: Orchestrates any non-trivial development or analysis task end-to-end — discovery, alignment, blueprint, registration, implementation and delivery. Routes to a branch (feature/bugfix/refactor/analysis) and reuses specialized skills (grilling, domain-modeling, tdd, diagnose, to-tickets, create-pr, prototype). Use when starting a feature, bugfix, refactor, or codebase analysis/audit, or when the user says "let's build this", "let's implement", "analyze X", or invokes /develop.
---

# develop

A thin **router** that gives every piece of work the same backbone — *align before coding* — while delegating the middle to the right specialized skill.

## Governing principle (read first)

**This skill owns the PROCESS. Each repo owns its CONVENTIONS in `.context/`.**
Never hardcode repo-specific rules (test patterns, CI commands, architecture) here.
At every step that needs conventions, **read the repo's `.context/`** (`testing.md`,
`architecture*.md`, `good_practices.md`, `styling.md`, and `CLAUDE.md`/`AGENTS.md`). If a needed
convention file is missing, **say so and ask** — never invent it.

> This armazón is **opinionated**: it assumes **DDD + hexagonal architecture + strict TDD**.
> See [PHILOSOPHY.md](../../PHILOSOPHY.md). Framework- and project-specific detail (naming,
> layering, DI wiring) lives in the repo's `.context/architecture.md`, not here.

## Step 0 — Detect the branch (infer + confirm)

Infer the work type from the request and the impact analysis, then **confirm in one line**
before proceeding ("I'll treat this as a *bugfix*, ok?").

| Branch | When | Execution core | Exit gate |
|--------|------|----------------|-----------|
| **feature** | new code / endpoint / use case | TDD loop (`tdd`) — RED first | tests + build + visual (if UI) → PR |
| **bugfix** | something broken / regression | `diagnose` → RED regression test | regression test green → PR |
| **refactor** | behavior-preserving change | existing tests as the contract | tests still green → PR |
| **analysis** | audit / investigation, no code | discovery + adversarial verification | verified findings report → **no PR** |

**One primary branch per task.** If work of a different nature appears mid-flight, it is a
scope signal → see Checkpoints. Don't mix it in (separate branch/PR).

See `branches/<branch>.md` for each execution core. Read it when you enter that branch.

## The flow (phases A–E)

### A · Discovery — always, depth scales

Map what the work touches **before** anchoring. Use `Plan`/`Explore` subagents. Scale by
signals: one `Explore` for a small bugfix; several in parallel (by subsystem) for wide impact.
When grepping, cover every source extension in play — a mixed codebase hides callers in files a
single-extension sweep misses.
Output: files, utilities, patterns, cross-cutting concerns affected.

### B · Alignment — grill almost always

Suggest a grilling to fix scope, needs and the decision tree, for anything but
trivial-mechanical work. **Infer + confirm in one line (like Step 0), then invoke the core
skills — not the user-only wrappers:**

- **Does this work touch the domain?** — i.e. does it *introduce or redefine a business noun*
  (order, customer, invoice, subscription…)? → confirm ("This touches the domain, I'll grill
  with domain modeling to sharpen the glossary, ok?"), then run **`/grilling` + `/domain-modeling`**
  so the glossary in `.context/glossary.md` gets fed in-flight.
- **Purely technical / mechanical** (internal endpoint, cache, wiring, no new concept named)?
  → confirm, then run **`/grilling`** alone (no docs).

Use the model-invocable cores (`/grilling`, `/domain-modeling`), not `grill-me`/`grill-with-docs`
— those are user-only entry points (`disable-model-invocation`) and are invisible to the router.
`.context/glossary.md` is kept alive **only** through this step — the alignment grilling is the
sole mechanism that maintains it. For risky decisions (state machines, data models), suggest a
throwaway scratchpad prototype first. **Grilling: confirm in one line → on your "yes", run.**

### C · Blueprint — the single human approval gate

Produce the plan via plan mode: context, decisions, numbered steps, file table,
compatibility, verification. **Declare visual impact here** (yes/no) so the later visual
checkpoint is predictable. If signals warrant (many slices, dependency ordering), suggest
`/to-tickets` for vertical tracer-bullet slices. This is the **only** mandatory human
approval; D–E then run autonomously except for the Checkpoints below.

### D · Registration — after approval only

1. Create a task/issue in your **issue tracker** (see `docs/agents/issue-tracker.md`; GitHub by
   default). Run `/setup` once per repo if the tracker isn't configured yet.
2. Create the branch **by hand**, before any commit, following your repo's branch-naming
   convention. Commits must never land on the main branch.
3. Keep the blueprint in the scratchpad, linked from the tracker task — never scattered `.md` in
   the repo tree.

### E · Implementation loop

1. **Build** = run the branch's execution core (`branches/<branch>.md`). For feature/bugfix
   this is the **TDD loop, RED-first — inomitible**, not "build then test".
2. **Hardening (two axes + mechanical):**
   - *Standards* — fresh-eyes review: spawn a **fresh subagent** to review the diff against the
     repo's `.context` (real tests? value objects over primitives? ports/adapters respected?
     defensive smells?).
   - *Spec* — separately, does the diff implement **what the approved blueprint (phase C) /
     tracker task actually asked for**? Missing requirements, scope creep, or requirements
     implemented wrong. Keep this axis distinct from Standards — clean code that builds the wrong
     thing still fails here.
   - *Mechanical* — cheap pattern checks (e.g. loose assertions, raw literals in tests) per repo
     conventions.
   Fix what review finds **before** the gate.
3. **Verification gate** — **discover** the repo's CI commands (package.json / CI / `.context`),
   don't hardcode. Run in order, stop at first failure. Ask once if undiscoverable.
4. **Deliver** with `/create-pr` (the branch already exists): short PR (what/why + tracker link),
   full detail in the task.
5. **Summary** — print a table: PR URL + files changed (consolidated if multiple slices).

## Checkpoints (hard stops, by trigger — not by phase)

D–E run autonomously **except** when a trigger fires:

1. **Visual impact declared** → confirm in the browser **before** `/create-pr` (green
   typecheck/lint ≠ correct render).
2. **Out-of-scope work appears** → **stop & ask if it blocks** the main work; otherwise **note it
   and continue**, report at the end (never fold it into this PR).
3. **Genuine design gap** → stop & ask.

## Delegation

Two kinds. **Cores** (`grilling`, `domain-modeling`) are model-invocable — the router confirms
in one line, then invokes them directly (they are *not* the user-only `grill-me`/`grill-with-docs`
wrappers). **Entry-points** (the rest) are direct user skills: the router **suggests** them; on
your explicit "yes" it runs the full skill (never a diluted inline version, never silently).

| Skill | Phase | Default |
|-------|-------|---------|
| `grilling` (core) | B | almost always — the alignment interview |
| `domain-modeling` (core) | B | added to `grilling` when work touches the domain (introduces/redefines a business noun) |
| `to-tickets` | C | by signals (size, slices, deps) |
| `tdd` | E (feature/bugfix) | inomitible |
| `diagnose` | E (bugfix) | always for bugs |
| `create-pr` | E (delivery) | always (non-analysis) |

## Where things live (two homes)

- **Process** → this skills armazón. One source of truth for *how we work*.
- **Conventions** → `<repo>/.context/` (per repo). What's specific to each repo.
- **Ephemeral** (blueprint, analysis report) → scratchpad, linked from the tracker. Never
  scattered `.md` in the repo tree.
