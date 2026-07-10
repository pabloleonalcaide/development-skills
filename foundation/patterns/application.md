# Patterns · Application

Opinionated shapes for the application layer. Base-class/decorator names are your repo's
convention; the shapes are the point.

## Use cases: Command vs Query

- **Command use case** (write): extends a command base class parameterized `<Request, Response,
  Aggregate>`; receives the event bus. Its execute method: (1) validates input and converts to VOs,
  (2) fetches entities via finders, (3) validates business rules in the domain, (4) runs the logic,
  (5) persists, (6) returns `[Response, Aggregate]` so the aggregate's events publish automatically.
  Audited via a decorator; errors logged automatically.
- **Query use case** (read): extends a query base class `<Request, Response>`; **no** event bus, **no**
  events published, returns the `Response` directly. Read-only.

```ts
export class ConfirmOrder extends CommandUseCase<ConfirmOrderRequest, ConfirmOrderResponse, Order> {
  constructor(private readonly orders: OrderRepository) {
    super();
  }

  async execute(req: ConfirmOrderRequest): Promise<[ConfirmOrderResponse, Order]> {
    const order = await new OrderFinder(this.orders).byId(OrderId.of(req.orderId)); // (2) fetch
    order.confirm();                    // (3)(4) rule + event recorded in the domain
    await this.orders.update(order);    // (5) persist
    return [{ orderId: order.id.value }, order]; // (6) returning the aggregate publishes its events
  }
}
```

## CQRS with a Query Bus

An alternative, more message-oriented read path: the query is a typed object (`Query<Response>`)
with an `of()` factory; the handler extends a query-handler base, auto-registers by its `queryName`,
and exposes `handle(query)`. Prefer it for reads reused from several places/contexts; use a plain
QueryUseCase for reads within the same context.

```ts
export class GetOrderByIdQuery implements Query<OrderView> {
  static of(orderId: string): GetOrderByIdQuery {
    return new GetOrderByIdQuery(orderId);
  }
  private constructor(readonly orderId: string) {}
}

export class GetOrderByIdHandler extends QueryHandler<GetOrderByIdQuery, OrderView> {
  queryName = GetOrderByIdQuery.name;
  constructor(private readonly orders: OrderReadModel) {
    super();
  }
  async handle(query: GetOrderByIdQuery): Promise<OrderView> {
    return this.orders.viewById(query.orderId);
  }
}
```

### Query naming on a shared bus
If one query bus serves all contexts and indexes handlers by the query's **class name** (failing on
a duplicate registration), **prefix each query name with its context** to avoid collisions. Apply
the prefix consistently across the whole triad: the Query class, the Response interface, and the
Handler (`queryName = Query.name`), plus the folder/file path. E.g. `SalesGetOrderByIdQuery` vs
`FulfillmentGetOrderByIdQuery`.

## Authorized handler

Separate authorization from logic: the use case holds only business logic; a separate **authorized
handler** declares the required actions/permissions, extracts the tenant identifier from the
request, and delegates to the use case.

## Controllers

A thin transport boundary: (1) extract data from the request and the authenticated user, (2) invoke
the use case(s), (3) send the response, (4) translate external-service errors into your own. Route
registration adds validators and middleware (authentication, etc.). No business logic.

```ts
export class ConfirmOrderController extends BaseController {
  constructor(private readonly confirmOrder: ConfirmOrder) {
    super();
  }
  async handle(req: Request, res: Response): Promise<void> {
    const [result] = await this.confirmOrder.execute({ orderId: req.params.id }); // no business logic
    this.ok(res, result);
  }
}
```

## Event handlers

React to domain events: declare which events they subscribe to, and in `on(event)` check the type
(`instanceof`) before firing the effect (e.g. send an email, publish tracking).

```ts
export class SendOrderConfirmation extends EventHandler {
  subscribedTo = [OrderConfirmed.name];
  constructor(private readonly mailer: Mailer) {
    super();
  }
  async on(event: DomainEvent): Promise<void> {
    if (!(event instanceof OrderConfirmed)) return; // type check before the side effect
    await this.mailer.sendOrderConfirmed(event.orderId);
  }
}
```
