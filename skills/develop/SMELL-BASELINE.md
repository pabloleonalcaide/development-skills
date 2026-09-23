# Smell baseline — Standards reviewer

> Input for the *Standards* axis of the hardening (phase E2). **Paste this file into the
> reviewer's prompt verbatim** — a smell named without its definition finds different things on
> each run. The repo's documented conventions (`.context/`) **outrank** anything here.
>
> Report only smells present **in the diff**, each with `file:line`, the smell, and the fix.

## The smells (after Fowler, *Refactoring*)

| Smell | What it looks like | Usual fix |
|-------|--------------------|-----------|
| **Mysterious name** | A name that doesn't say what the thing does or holds. | Rename; if no good name comes, the design is muddled. |
| **Duplicated code** | The same logic shape in more than one place. | Extract and unify. |
| **Long function** | One function working at several levels of abstraction. | Extract functions named by intent. |
| **Long parameter list** | Many parameters, often travelling together. | Parameter object, or pass the whole object. |
| **Mutable shared data** | State that can change from anywhere. | Encapsulate; make it immutable. |
| **Divergent change** | One module edited for several unrelated reasons. | Split by reason to change. |
| **Shotgun surgery** | One change forces edits across many modules. | Move the related behavior together. |
| **Feature envy** | A method more interested in another object's data than its own. | Move the method to where the data lives. |
| **Data clumps** | The same group of fields/params keeps appearing together. | Extract a class or value object. |
| **Primitive obsession** | Domain concepts as primitives (string email, number money). | Introduce a value object. |
| **Repeated switches** | The same switch / if-chain on a type code in several places. | Polymorphism. |
| **Speculative generality** | Hooks and abstractions for needs that don't exist yet. | Inline; delete. |

## Suppressions under hexagonal architecture

These look like smells but are the architecture — don't report them:

- **A port with a single adapter** is not speculative generality: the port *is* the boundary.
  (An interface *inside* the domain with one implementation and no boundary reason still is.)
- **A thin use case** that orchestrates a port call, or a driving adapter that only maps a request
  to a command, is not a middle man.
- **DTOs, commands, events and read models** are meant to be plain data (not a "data class" smell).
- **Similar mapping code in two adapters** for different external systems is not duplication when
  each changes for its own reason.
