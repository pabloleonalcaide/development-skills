# Patterns · Domain

Opinionated building blocks for the domain layer. Strong defaults — adopt what fits. The exact
base-class and decorator names are your repo's convention (`.context/architecture.md`); the shapes
below are the point.

## Value Objects

Encapsulate a primitive with validation and behavior.
- Hierarchy: `ValueObject<T>` base → `StringValueObject`, `NumberValueObject`, `EnumValueObject<T>`;
  over string, an `IdValueObject` for identifiers.
- Traits: immutable (no setters); static factory (`of()`); validation in the constructor (fail
  fast); business methods that return new instances; implements `equals()` and `toString()`.
- Use VOs instead of primitives for any domain concept with rules (ids, emails, amounts, enums).

```ts
export class EmailAddress extends StringValueObject {
  static of(value: string): EmailAddress {
    return new EmailAddress(value);
  }
  protected constructor(value: string) {
    super(value);
    if (!value.includes("@")) throw new InvalidEmailError(value); // fail fast in the constructor
  }
}
```

## Entities & Aggregate Roots

- Extend a generic aggregate root parameterized by their primitives.
- **Private constructor**; created only via factories: `fromPrimitives(primitives)` (rehydrate from
  persistence) and `create(params)` (new instance, which **records the creation event**).
- Business methods encapsulate the transition, check the invariant, and **record the domain event**.
- Accessor getters, **no public setters**; internal mutable properties are private.
- `toPrimitives()` to serialize toward persistence.

```ts
export class Order extends AggregateRoot<OrderPrimitives> {
  private constructor(
    private readonly _id: OrderId,
    private _status: OrderStatus,
  ) {
    super();
  }

  static create(id: OrderId): Order {
    const order = new Order(id, OrderStatus.Draft);
    order.registerEvent(new OrderCreated(id.value)); // creation event
    return order;
  }

  static fromPrimitives(p: OrderPrimitives): Order {
    return new Order(OrderId.of(p.id), OrderStatus.of(p.status));
  }

  confirm(): void {
    if (!this._status.isDraft()) throw new OrderNotConfirmableError(this._id.value); // invariant
    this._status = OrderStatus.Confirmed;
    this.registerEvent(new OrderConfirmed(this._id.value)); // tell-don't-ask + record the event
  }

  get id(): OrderId {
    return this._id;
  }

  toPrimitives(): OrderPrimitives {
    return { id: this._id.value, status: this._status.value };
  }
}
```

## Domain Services

Domain logic that doesn't belong to a single entity. Use for operations across entities, complex
validations, reusable lookups, cross-aggregate calculations. Common shapes:
- **Finder**: looks up and throws if not found.
- **Verifier**: validates business rules.
- **Calculator**: complex calculations.

```ts
export class OrderFinder {
  constructor(private readonly orders: OrderRepository) {}
  async byId(id: OrderId): Promise<Order> {
    const order = await this.orders.findById(id);
    if (!order) throw new OrderNotFoundError(id.value); // finder throws; callers get a real Order
    return order;
  }
}
```

## Domain Events

Notify that something meaningful happened. Lifecycle:
1. **Record**: the entity records the event (`registerEvent(...)`) inside its business method.
2. **Publish**: the use case publishes the aggregate's events
   (`eventBus.publish(aggregate.pullDomainEvents(), origin)`).
3. **React**: subscribed event handlers react.
- Rule of thumb: within one use case, only the root aggregate publishes its own events.
- **Auditable events**: a decorator marks events that must be recorded in an audit log; the
  mechanism auto-subscribes to them at startup. If a use case emits an auditable event, its use-case
  decorator must declare the matching audit action (they're complementary).
