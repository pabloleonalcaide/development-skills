# .context/ — per-repo conventions (the slots)

The skills in this armazón are **agnostic**. Everything specific to *your* repo lives here, in `.context/`, at the repo root (or per-app in a monorepo). The skills read these files; they hardcode nothing.

Copy this folder into your repo as `.context/` and fill each file in. Empty is fine — the skills degrade gracefully and ask when a needed convention is missing.

| File | Read by | Holds |
|------|---------|-------|
| `architecture.md` | `develop`, `tdd`, review | your layering, ports/adapters, DI wiring, naming |
| `testing.md` | `tdd`, `diagnose`, `develop` | test levels, tools, what a good test looks like |
| `good_practices.md` | review | the checklist a fresh-eyes review applies |
| `styling.md` | `create-pr`, `tdd` | naming, commit conventions |
| `glossary.md` | `domain-modeling`, `to-spec`, `to-tickets` | the canonical domain vocabulary (produced by `/domain-modeling`) |
| `decisions/` | `domain-modeling`, `to-spec`, `to-tickets` | one file per durable decision (`0001-slug.md`) |

The domain files (`glossary.md`, `decisions/`) are **produced** by `/domain-modeling` during alignment — you don't have to write them by hand.
