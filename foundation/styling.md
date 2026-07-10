# Styling & conventions (core)

Naming, type-safety and commit conventions. Written for a typed language (TypeScript by example);
generalize the tool names to your linter/formatter.

## Type safety (strict)

Turn strict mode fully on: no implicit `any`, no unused locals/params, no implicit returns, no
fallthrough, no unchecked indexed access, no unreachable code.

## Code style

- **Named exports** (no default exports).
- Avoid deep relative imports.
- **Explicit return types** on functions.
- No `async` without `await`.
- Template literals over string concatenation; object shorthand; a blank line before `return`/`if`
  where it aids reading.
- Explicit visibility modifiers always; `readonly` wherever possible.
- **No `any`** — use concrete types, generics, or `unknown` with narrowing.
- `T[]` over `Array<T>`; optional params last.
- **Specific errors** over generic ones; catch by type.
- `async/await` over `.then()` chains.

## Naming

- `PascalCase` for classes/types, `camelCase` for variables/functions, `UPPER_SNAKE_CASE` for
  global constants.
- Prefix private mutable properties with `_`.
- Booleans read as `is/has/can…`; avoid negative booleans.

## Commits (Conventional Commits)

- Format: `<type>: <description>` — types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, etc.
- Type mandatory; lowercase; imperative mood; no trailing period; be specific.
- Footer `BREAKING CHANGE:` when applicable.

## Repo-specific (fill in)

- Linter/formatter and its config: `...`
- Branch-naming convention: `...` (e.g. `type/short-slug`)
- PR rules: required reviewers, labels, CI checks (read by `create-pr`; it hardcodes none).
- Commit language / scope policy: `...`
