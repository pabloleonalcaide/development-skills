# Testing (core)

How tests work, so `tdd` and `diagnose` pick the right level. Fill in the concrete tools/commands
for your repo; the levels and invariants below are the doctrine.

## Levels

- **unit** — a use case or domain element in isolation, dependencies mocked. Fast.
- **integration** — a use case (or repository) against real adapters (e.g. a real database, often
  via an ephemeral container).
- **integration-no-infra** — a gateway against an external service, with HTTP mocked/recorded.
- **e2e** — a driving adapter end to end (HTTP endpoint / CLI), real database, external gateways
  mocked.

## Test invariants (strict)

1. **Mock only through a single wrapper**, and reset mocks in `beforeEach`.
2. **No magic literals for identities** — derive ids/values from Builders or VO factories so
   arrange and assert stay consistent.
3. **No `expect.any()`** — assert the real value; use `objectContaining` only when the subset is
   intentional.
4. **External HTTP via recordings** — never hit real endpoints.

## What to test directly vs black-box

- **Application handlers** (use cases, query handlers, event handlers, authorized handlers) are
  **always** tested directly — they own observable behavior.
- **Domain elements** (aggregates, value objects, domain services / finders / verifiers) are **not**
  tested in isolation — they're covered **black-box through the use case** that exercises them,
  asserting the observable result (what got persisted, which events, which errors).
- **Exception**: test a domain element directly only when its complexity warrants it (non-trivial
  calculations, many branches, intricate invariants).

```ts
// ✅ cover the Order aggregate + OrderStatus VO BLACK-BOX, through the use case that exercises them
it("confirms a draft order and emits OrderConfirmed", async () => {
  const order = new OrderBuilder().draft().build();      // Builder — no magic literals
  const orders = new InMemoryOrderRepository([order]);

  const [, aggregate] = await new ConfirmOrder(orders).execute({ orderId: order.id.value });

  expect(orders.saved(order.id)).toHaveStatus("confirmed");              // observable: persisted state
  expect(aggregate.pullDomainEvents()).toContainEqual(                   // observable: event emitted
    new OrderConfirmed(order.id.value),
  );
});
// No separate test for Order.confirm() or the OrderStatus value object — they're covered here.
// You'd add a dedicated test only if, say, OrderStatus had intricate transition rules of its own.
```

## Practices

- **AAA** (arrange–act–assert), one behavior per test.
- Use **Builders** for test data.
- Tests are independent and isolated; clean up (drop collections in `afterEach`, close connections
  in `afterAll`).
- Assert side effects (events published, repository calls).
- Descriptive names: "should … when …".

## Repo-specific (fill in)

- Test runner and config: `...`
- Ephemeral DB / containers: `...`
- Commands — run unit: `...` · full suite + typecheck/lint (the verification gate): `...`
