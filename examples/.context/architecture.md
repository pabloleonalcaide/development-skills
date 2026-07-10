# Architecture

> Template. Describe *your* concrete hexagonal setup. The skills assume DDD + ports/adapters
> in spirit (see PHILOSOPHY.md); this file pins the specifics for this repo.

## Layers & dependency rule
Dependencies point inward: adapters → application (use cases) → domain. The domain depends on
nothing. Example:

- **domain/** — entities, value objects, aggregates, domain services. Pure, no I/O.
- **application/** — use cases orchestrating the domain; declare ports (interfaces) they need.
- **infrastructure/** — adapters implementing the ports (db, http, queues).
- **interface/** — driving adapters (controllers, CLI, jobs).

## Naming conventions
Fill in *your* conventions, e.g.:
- Use case entry point: `execute()` / `handle()` / `internalExecute()` — pick one, state it here.
- Value objects wrap primitives (no bare `string`/`number` for domain concepts).
- Ports named by capability (`OrderRepository`, `Clock`, `PaymentGateway`).

## Dependency injection
How adapters get wired to ports (container, manual composition root, etc.). Where to register a
new repository / use case so it resolves at runtime.

## Where things go
A new endpoint touches: interface adapter → use case → domain → port → infrastructure adapter.
State the folders and the order.
