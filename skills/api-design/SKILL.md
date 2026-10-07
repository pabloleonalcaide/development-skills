---
name: api-design
description: Design stable public interfaces — HTTP endpoints, event payloads, module boundaries, SDK-style ports — and make retried operations safe with idempotency keys. Use when adding or changing an endpoint, a request/response or event contract, an error format, a public module interface, or any operation that can be retried (payments, webhooks, jobs, queue consumers). Invoked by /develop when the blueprint declares API contract impact.
---

# API design

Every observable behavior of an interface becomes a contract once someone depends on it
(**Hyrum's Law**). Design the contract first, change it by adding, and make every operation that
can be retried safe to retry.

## When NOT to use

- Internal functions with a single caller in the same module — that is ordinary code design.
- Choosing *where* a seam goes for testing — that is `tdd`'s interface-design guidance.

## Process

1. **Contract first.** Write the request, response, error and event shapes (as types or a
   schema) before the implementation, and get them into the blueprint. Name the consumers.
2. **One error format** across the API: a stable machine-readable `code`, a human `message`, and
   optional `details`. Consumers branch on `code`, never on `message`.
3. **Change by adding.** New optional fields, new endpoints, new event types. Renaming, retyping,
   removing a field or tightening validation is a **breaking change** → version it or run an
   expand/contract migration (`deprecation`).
4. **Validate at the edge only.** The boundary turns raw input into typed values; inner layers
   trust their types and don't re-validate.
5. **Predictable naming.** Resources as plural nouns, actions as HTTP verbs, the same name for
   the same concept everywhere (match the project glossary).
6. **Make illegal states unrepresentable.** Discriminated unions for variants (`{status:
   'paid', paidAt}` vs `{status: 'pending'}`), branded types for ids that must not be mixed.
7. **Retried operations get an idempotency key.** Any operation that a client, a queue or a
   retry policy may deliver twice — open [IDEMPOTENCY.md](IDEMPOTENCY.md) when you reach it.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Nobody uses that field" | You can't see every consumer. Under Hyrum's Law someone does; prove zero consumers before removing. |
| "It's a small rename, clients will adapt" | A rename is a delete plus an add. Every client breaks at once. |
| "Retries are rare, idempotency can wait" | Retries happen exactly when things go wrong — timeouts, deploys, network blips — and that's when a double charge hurts. |
| "A timestamp in the key makes it unique" | Unique per attempt, so every retry looks new. Derive the key from the intent. |

## Red Flags

- A response field removed, renamed or retyped in the diff without a version or migration plan.
- Error handling that matches on message strings.
- Validation of the same input repeated in several layers.
- An idempotency key built from `Date.now()`, a random UUID per attempt, or the request count.
- "Check if exists, then create" without a unique constraint.

## Verification

- [ ] Contract types/schema written and listed in the blueprint, with consumers named
- [ ] No breaking change, or a version/expand-contract step is planned
- [ ] Errors use the shared format with a stable `code`
- [ ] Every retryable operation has an intent-derived idempotency key and a test that sends it twice
