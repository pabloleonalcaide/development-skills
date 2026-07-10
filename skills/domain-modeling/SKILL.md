---
name: domain-modeling
description: Capture and sharpen a repo's domain language and decisions into .context/ — challenge terms against the glossary, sharpen fuzzy language, cross-reference with code, and record durable decisions. Use alongside an alignment/grilling session when the work touches the domain, or when the user wants to model the domain, sharpen terminology, or maintain the glossary.
---

Capture domain language and decisions into the repo's `.context/` as they crystallise. Run this alongside a `/grilling` session (or on its own) whenever the work touches the domain.

## Domain awareness

`.context/` is this repo's single home for durable knowledge. Domain docs live there:

- **Glossary** → `.context/glossary.md` — the canonical vocabulary of this context.
- **Decisions** → `.context/decisions/` — one file per decision (`0001-slug.md`, `0002-slug.md`, …).

During codebase exploration, read `.context/glossary.md` if it exists so you can challenge new terms against it. Create files lazily — only when you have something to write. If no `glossary.md` exists, create it when the first term is resolved. If no `decisions/` exists, create it when the first decision worth recording appears.

## During the session

### Challenge against the glossary

When the user uses a term that conflicts with the existing language in `.context/glossary.md`, call it out immediately. "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account' — do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"

### Update the glossary inline

When a term is resolved, update `.context/glossary.md` right there. Don't batch these up — capture them as they happen. Use the format in [GLOSSARY-FORMAT.md](./GLOSSARY-FORMAT.md).

`glossary.md` should be totally devoid of implementation details. Do not treat it as a spec, a scratch pad, or a repository for implementation decisions. It is a glossary and nothing else.

### Offer decision records sparingly

Only offer to record a decision in `.context/decisions/` when all three are true:

1. **Hard to reverse** — the cost of changing your mind later is meaningful
2. **Surprising without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip it. Use the format in [DECISIONS-FORMAT.md](./DECISIONS-FORMAT.md).
