# Architecture (core)

The non-negotiable shape: DDD + hexagonal. Framework- and repo-specific wiring extends this file;
the principles below do not bend.

## Fundamental principles

1. **Layer separation**: Domain → Application → Infrastructure.
2. **Dependency inversion**: outer layers depend on inner layers, never the reverse.
3. **Pure domain**: business logic depends on no framework and no infrastructure.
4. **Event-driven**: contexts communicate through domain events.

## Layers

- **Domain** — entities/aggregates, value objects, pure business rules, domain services, domain
  events, domain errors, and the **ports** (abstract repositories/gateways) the domain needs. No I/O.
- **Application** — use cases that orchestrate collaborators; transactions; authorization;
  complex workflows. Orchestrates, does not implement business rules.
- **Infrastructure** — persistence, external APIs, email/logging/i18n, and the **adapters** that
  implement the domain's ports.

## Bounded contexts

- **Golden rule**: a bounded context NEVER imports entities, repositories or services from another
  context — only from a shared/cross-cutting domain module.
- **Duplicate the model per context**: each context keeps its own version of the entities it needs,
  with only the fields it cares about. Justification: independent evolution, simplicity, model
  clarity, and "same data source, different view" (same store, different mappers).

## Reads that cross a boundary

A read never reaches directly into another module's/context's domain (repo/finder/service):
- **Cross-module, same context** → dispatch a `Query` on a query bus; the module that owns the data
  resolves it. The consumer depends only on the message + its response DTO.
- **Cross-context** → the consuming context keeps its **own projection** of the data (same source,
  its own mapper, its own shape) and exposes **its own** query. Never dispatch another context's
  query nor read its models.

## Hexagonal structure (per context)

```
context/
├── domain/            # entity/aggregate, primitives, ports (repository, gateway),
│                      # domain services, domain events, domain errors
├── application/       # use cases, authorized handlers, event handlers
└── infrastructure/    # adapters (persistence, external services), models/schemas,
                       # mappers domain↔persistence
```

## Dependency rules (enforce with architecture tests, not the linter)

- **Domain** must NOT depend on: application, infrastructure, or external libraries (only the
  shared domain).
- **Application** must NOT depend on: infrastructure.
- Allowed dependencies:
  - presentation → domain/application of the contexts + shared
  - infrastructure → domain + application + shared
  - application → domain + shared domain
  - domain → shared domain only (never infrastructure)
- Verify these boundaries with an **architecture test suite** (static analysis of the import
  graph). The linter covers style, not boundaries.
