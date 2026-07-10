# Patterns · Operations

Opinionated shapes for scheduled/background work.

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
