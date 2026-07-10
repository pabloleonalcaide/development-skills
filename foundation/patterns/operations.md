# Patterns · Operations

Opinionated shapes for scheduled/background work. Names are your repo's convention; the shapes are
the point.

## Cron jobs

Scheduled infrastructure tasks. Distillable patterns:

- **Distributed lock**: a lock port (`acquire(jobName, ttl)` / `release(jobName)`) guarantees only
  one instance runs the job across several servers; if `acquire` returns `false`, skip that run. The
  implementation can lean on a store with TTL.
- **Base-class hierarchy**: a base that manages lock, logging and error handling; a variant that
  additionally turns an alert result into a notification.
- **`Alert` value object**: `ok()` / `warning(msg)` / `critical(msg)` with `requiresNotification`
  (true when not ok). Use cases invoked by alerting crons return an `Alert`.
- **Auto-registration by decorator**: jobs marked with a decorator are instantiated from the DI
  container and started when the app boots.

```ts
export class ExpireStaleOrdersJob extends CronJob {
  jobName = "expire-stale-orders";
  constructor(
    private readonly lock: CronLock,
    private readonly expireOrders: ExpireStaleOrders,
  ) {
    super();
  }
  async run(): Promise<void> {
    if (!(await this.lock.acquire(this.jobName, 60_000))) return; // only one instance runs
    try {
      await this.expireOrders.execute();
    } finally {
      await this.lock.release(this.jobName); // always release
    }
  }
}
```

```ts
// alerting variant: the use case returns an Alert; the base turns it into a notification
export class Alert {
  private constructor(
    readonly level: "ok" | "warning" | "critical",
    readonly message?: string,
  ) {}
  static ok(): Alert {
    return new Alert("ok");
  }
  static warning(message: string): Alert {
    return new Alert("warning", message);
  }
  static critical(message: string): Alert {
    return new Alert("critical", message);
  }
  get requiresNotification(): boolean {
    return this.level !== "ok";
  }
}
```
