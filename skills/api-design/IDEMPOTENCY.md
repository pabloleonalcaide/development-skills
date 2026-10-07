# Honouring an idempotency key

Open this when an operation can be delivered more than once: client retries, webhook
redelivery, queue at-least-once delivery, job re-runs, a provider call behind a timeout.

## 1. Derive the key from the intent, not the attempt

The key names *what the caller wants to happen*, so every retry of the same intent produces the
same key.

- ✓ `charge:${invoiceId}`, `refund:${paymentId}:${amount}`, `welcome-email:${userId}`
- ✗ `${orderId}:${Date.now()}` — a timestamp is a random UUID in disguise: unique per attempt.
- ✗ `randomUUID()` generated inside the retry loop.

If the caller sends the key (an `Idempotency-Key` header), it must be generated **once** per
intent on the caller's side and reused on every retry.

## 2. Reserve atomically

Insert the key into storage with a **unique constraint** before doing the work. "Check, then
act" leaves a window in which two concurrent deliveries both see "not found" and both act.

```
insert {key, status: 'in_progress', payloadHash}   -- unique index on key
  ok        → do the work, then update {status: 'done', result}
  duplicate → go to 3
```

## 3. Handle the duplicate by state

- `done` with the **same payload hash** → return the stored result, do nothing.
- `done` with a **different payload hash** → reject (409/422): the same key was reused for a
  different intent — a caller bug.
- `in_progress` → pick a policy and document it: return 409 "retry later", wait and poll, or
  return 202 Accepted.

## 4. Three outcomes, not two

A call to a third party can **succeed, fail or be unknown** (timeout, connection reset after
send). Unknown is not failure: retrying blindly may execute twice. Either pass your idempotency
key to the provider (so a retry is safe) or reconcile by querying the provider before retrying.

## 5. Retention

Keep keys at least as long as the longest retry chain that can deliver the same intent —
including redelivery from a dead-letter queue and manual replays. Expiring earlier silently
re-enables duplicates.

## 6. Test

- Same key twice, sequentially → one side effect, same response.
- Same key twice, concurrently → one side effect.
- Same key, different payload → rejected.
- Provider timeout → no blind retry without the key.
