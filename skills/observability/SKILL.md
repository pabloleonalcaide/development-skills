---
name: observability
description: Instrument code so production behavior is visible and diagnosable — structured logs with correlation ids, metrics, traces, symptom-based alerts and minimal runbooks. Use when adding an endpoint, job, cron, queue consumer or third-party integration, when a production issue was hard to diagnose, or when the user asks for logging, metrics, tracing, dashboards or alerts. Invoked by /develop when the blueprint declares observability impact.
---

# Observability

Instrument for the questions the on-call will ask, not for the code you wrote. **Metrics tell you
*that* something is wrong, traces tell you *where*, logs tell you *why*.**

## When NOT to use

- Temporary debug logging while diagnosing a bug — that is `diagnose` (tagged logs, removed after).
- Pure refactors with no new entry point or integration.

## Process

1. **Define "working" first.** Write 2-4 questions the on-call will ask about this code at 3 a.m.:
   "Did last night's run process every record?", "Are payments to provider X failing?", "Which
   tenant is slow?". Every signal you add must answer one of them; drop the rest.
2. **Structured logs, one event per meaningful step.** JSON, stable field names, a level that
   means something (`error` = someone must act). Every line carries:
   - a **correlation id** propagated across calls and queue hops;
   - an **`entryPoint`** field when several origins (HTTP, cron, consumer) write to the same
     sink — so a line can be traced to what started it;
   - the business identifiers needed to act (ids, not personal data).
3. **Metrics: RED for services, USE for resources.** Rate, Errors, Duration per endpoint/job;
   Utilization, Saturation, Errors for pools and queues. Report latency as **percentiles**
   (p50/p95/p99), never averages.
4. **Watch cardinality.** Labels are bounded sets (endpoint, status class, provider). **Never** a
   label per user, tenant, id or free text — that belongs in logs or trace attributes.
5. **Traces at the boundaries.** A span per inbound request, outbound call and queue hop, with the
   correlation id; prefer the platform's OpenTelemetry setup over hand-rolled timing.
6. **Alert on symptoms, not causes.** Two severities: **page** (users are hurting now) and
   **ticket** (will hurt soon). Every alert gets a 3-line runbook: what it means, first check,
   who owns it.
7. **Verify the telemetry itself.** Trigger each new log, metric and alert once (in a test,
   staging or a dry run) and confirm it arrives where the on-call will look.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We'll add logs when something breaks" | When it breaks you need the logs from *before* it broke. |
| "Log everything, we'll grep later" | Noise hides the signal and the bill grows; log what answers the on-call's questions. |
| "The average latency is fine" | Averages hide the tail; the p99 is what your slowest users feel. |
| "Add the user id as a label, it's handy" | Unbounded cardinality explodes the metrics backend. Put it in the log line. |
| "The alert is configured, done" | An alert never fired is an alert never tested. Fire it once. |

## Red Flags

- A new cron, job or consumer that logs nothing on success — you can't tell "ran fine" from "didn't run".
- `console.log` / unstructured strings in production code.
- A catch block that logs without the correlation id or the identifiers needed to act.
- Personal data or secrets in log lines.
- An alert without a runbook or owner.

## Verification

- [ ] The on-call questions are written down and each one is answerable from the new signals
- [ ] Logs are structured, carry correlation id (and `entryPoint` if the sink is shared), no PII
- [ ] Metric labels are bounded; latency as percentiles
- [ ] Each new alert has severity, runbook and owner, and was fired once
