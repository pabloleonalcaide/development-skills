# Patterns · Infrastructure

Opinionated shapes for adapters and wiring. Names are your repo's convention; the shapes are the
point.

## Repositories (port + adapter)

- **Port**: an abstract class/interface in the **domain** with the methods the domain needs
  (`create`, `update`, `delete`, `findById`, business finders…), typed with VOs.
- **Adapter**: an implementation in **infrastructure** that uses `toPrimitives()` on save and a
  dedicated **mapper** (`toDomain`) on read; returns `undefined` when nothing is found.

```ts
// domain/ — the port
export abstract class OrderRepository {
  abstract update(order: Order): Promise<void>;
  abstract findById(id: OrderId): Promise<Order | undefined>;
}

// infrastructure/ — the adapter
export class SqlOrderRepository extends OrderRepository {
  constructor(private readonly db: Db) {
    super();
  }
  async update(order: Order): Promise<void> {
    await this.db.orders.upsert(order.toPrimitives()); // toPrimitives on the way out
  }
  async findById(id: OrderId): Promise<Order | undefined> {
    const row = await this.db.orders.find(id.value);
    return row ? OrderMapper.toDomain(row) : undefined; // mapper on the way in; undefined if absent
  }
}
```

## Gateway specialization (Facade)

When a gateway grows too large, decompose it into specialized sub-gateways (one per
responsibility) grouped under a **facade** that implements the domain's single port and delegates
each method to the right sub-gateway. The domain still depends on one port; each sub-gateway is
built, tested and reviewed in isolation.

```ts
// domain still depends on one port: PaymentGateway
export class PaymentGatewayFacade extends PaymentGateway {
  constructor(
    private readonly charges: ChargeGateway,
    private readonly refunds: RefundGateway,
  ) {
    super();
  }
  charge(o: Order): Promise<Receipt> {
    return this.charges.charge(o);
  }
  refund(r: Receipt): Promise<void> {
    return this.refunds.refund(r);
  }
}
```

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

```ts
container.register(OrderRepository, SqlOrderRepository);         // port → adapter, transient
container.register(EventBus, InMemoryEventBus, { singleton: true }); // stateless infra → singleton
const app = container.build();                                    // closes registration
subscribeEventHandlers(app);                                     // buses wired after build
```
