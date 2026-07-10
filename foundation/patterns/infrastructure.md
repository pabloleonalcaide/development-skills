# Patterns · Infrastructure

Opinionated shapes for adapters and wiring.

## Repositories (port + adapter)

- **Port**: an abstract class/interface in the **domain** with the methods the domain needs
  (`create`, `update`, `delete`, `findById`, business finders…), typed with VOs.
- **Adapter**: an implementation in **infrastructure** that uses `toPrimitives()` on save and a
  dedicated **mapper** (`toDomain`) on read; returns `undefined` when nothing is found.

## Gateway specialization (Facade)

When a gateway grows too large, decompose it into specialized sub-gateways (one per
responsibility) grouped under a **facade** that implements the domain's single port and delegates
each method to the right sub-gateway. The domain still depends on one port; each sub-gateway is
built, tested and reviewed in isolation.

## Dependency injection

- Register implementations against abstractions (**port → adapter**) in a central container.
- **Scopes**:
  - **Transient** by default — all business logic and most infrastructure.
  - **Singleton** only for expensive, stateless infrastructure (connection/clients, event/query
    buses, loggers).
  - **Request** rarely.
  - Do NOT use Singleton for business logic, mutable-state services, or repositories.
- **Startup order**: register infrastructure → register application → **build (closes
  registration)** → register/subscribe handlers to the buses (requires a built container).
- Don't register after build; don't resolve before build; don't register twice with different
  scopes.
