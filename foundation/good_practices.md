# Good practices (core)

The review checklist and the smells to avoid. `develop`'s hardening (Standards axis) applies this.

## When to use each layer

- **Domain**: entities with behavior, value objects with validation, pure business rules, domain
  events. No framework dependencies.
- **Application (use cases)**: orchestration of several collaborators, transactions,
  authentication/authorization, complex workflows. Orchestrates; does not implement rules.
- **Infrastructure**: persistence, external APIs, email/logging/i18n, and port implementations
  (adapters).

## Code smells → fix

- **Domain depending on infrastructure** → the domain depends on abstractions (ports);
  implementations live in infrastructure.
- **Use case with complex business logic** → move the rule into a value object (validate on
  construction), an entity, or a domain service.
- **Controller with business logic** → the controller only translates the transport: extract
  request data, invoke the use case, serialize the response.
- **Anemic domain model** (only getters/setters) → a rich model: business methods that encapsulate
  the transition and record domain events.

## Principles to follow

- **Dependency inversion**: high-level and low-level modules both depend on abstractions (ports),
  not on implementations.
- **Single responsibility**: one class, one reason to change. One use case per operation instead of
  a "Manager" that does everything.
- **Immutability**: value objects don't change after creation; operations return new instances.
- **Tell, don't ask**: tell the object what to do (`x.activate()`), don't read its state and decide
  outside.
- **Fail fast**: validate in the constructor / as early as possible and throw immediately.

## Efficient ("green") software

- Avoid duplicate operations/queries; reuse results.
- Replace N+1 with batch queries.
- Check before processing (count/validate before fetching and transforming collections).
- Release resources (close connections and listeners in teardown).
- Use the right data structure (a Map for O(1) lookups vs linear O(n) search).

## Checklists

**New use case**: define Request/Response interfaces · extend the command or query base class ·
tag it as a use case (with an audit action if it's a command) · implement the execute method ·
return `[Response, Aggregate]` for commands · add an authorization handler if applicable · register
it in the DI container · unit tests · create event handlers for the events it emits.

**New controller/endpoint**: extend the base controller · inject dependencies via constructor ·
extract data from body/query/user · invoke the use case(s) · respond with the response helper ·
handle specific errors · register the controller and its route with validators and middleware
(auth, CORS, rate-limit) · end-to-end tests.

**New entity/aggregate**: extend the aggregate root · define the primitives type · private
constructor taking VOs · `fromPrimitives()` and `create()` factories · `toPrimitives()` · business
methods · record domain events on meaningful changes · create specific domain errors · define the
repository port in the domain and its adapter + mapper in infrastructure · register it in DI ·
cover behavior via use-case tests (black box) unless complexity warrants a dedicated test ·
repository integration tests.

**New event handler**: extend the handler base class · declare the events it subscribes to ·
implement `on(event)` with a type check (`instanceof`) · register and subscribe it to the event
bus · unit tests.

**New repository**: define the abstract class/interface in the domain with all its methods ·
implement the adapter + model/schema + domain↔persistence mapper in infrastructure · register it in
DI (transient scope by default) · integration tests.

**New gateway (external service)**: define the port in the domain · implement the adapter in
infrastructure · handle the external service's errors and map its data to domain entities ·
register it in DI · integration tests with HTTP mocked/recorded.

**Code review**: no domain depending on infra · no use cases depending on infra · business logic in
the domain (not in use cases or controllers) · dependencies injected via constructor · VOs instead
of primitives · immutable entities (no public setters) · domain events on meaningful state changes ·
specific domain errors · happy-path and error tests · no unnecessary queries/processing · strict
types · linter green · commit message follows the convention.
