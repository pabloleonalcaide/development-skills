# Philosophy

`development-skills` is an **opinionated** agent workflow. It is not a neutral toolbox — it encodes a specific way of building software. If your project doesn't share these commitments, this armazón is not for you, and that's fine.

## The three commitments

### 1. Domain-Driven Design
Software is organized around the **domain**, not the framework. A canonical glossary (`/domain-modeling` → `.context/glossary.md`) keeps the language sharp: one word per concept, synonyms explicitly avoided, value objects over primitives. The names in the code match the names the business uses.

### 2. Hexagonal architecture (ports & adapters)
The domain sits at the center, independent of delivery mechanism and infrastructure. Use cases orchestrate; ports declare what the domain needs; adapters implement it at the edges. Dependencies point inward. The **concrete** wiring (naming, DI, layering) is project-specific and lives in `.context/architecture.md` — the skills themselves stay framework-agnostic.

### 3. Test-Driven Development (strict)
RED first, always. A failing test that fails *for the right reason*, then the minimal code to green, then refactor. Tests assert **behavior**, not implementation. For a bug, the regression test is the proof it existed and is gone — never optional.

## The through-line: align before code
Every non-trivial task earns the same backbone (`/develop`): discover → **align** (grill the decision tree before writing anything) → blueprint (one human approval gate) → implement → deliver. The single most important habit is refusing to code until the decisions are settled.

## What this is not
- **Not stack-agnostic in spirit.** It assumes a typed language and a domain worth modeling.
- **Not a home for repo-specific rules.** Those live in each repo's `.context/`.
- **Not a replacement for judgment.** The skills structure the work; they don't do the thinking.

## Credit
Derived from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT). The align-before-code flow, the grilling loop and the domain-modeling approach originate there; the `develop` router, the branch model, the cores/wrappers split and the agnostic packaging are this repo's.
