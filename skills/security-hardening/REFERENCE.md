# Security hardening — control catalogue

Open the section you need when you reach that code.

## Authentication and authorization

- Check authorization **on the resource**, server-side, on every request: load the resource,
  then check the caller may act on it. Never trust an id because it came from a "safe" page.
- Deny by default: a new endpoint without an explicit permission rule must fail closed.
- Model a permission as **(action, resource)**, not as "may call use case X" — use cases change,
  the action/resource pair is the stable contract.
- Session tokens: short-lived, rotated on privilege change, invalidated on logout.

## Input validation at the boundary

- Validate shape, type, length and range once, at the boundary, with a schema; inner layers then
  receive typed values (value objects), not raw strings.
- Reject unknown fields on write endpoints (mass assignment).
- Cap payload size, array length and nesting depth before parsing.

## Secrets

- Read secrets from the environment or a secret manager; never commit them, never log them.
- Leaked secret: **rotate first, then purge history** — purging alone leaves the old value valid.
- Redact in logs by key (`authorization`, `password`, `token`, `secret`, `cookie`).

## Webhooks and signed requests

- Verify the signature over the **raw body** before parsing it; reject on mismatch.
- Check a timestamp tolerance to prevent replay; process idempotently by event id.

## Outbound requests (SSRF)

- Allowlist hosts; do not fetch arbitrary user-supplied URLs.
- Resolve the host and check the IP is not private/loopback/link-local **at connect time** —
  checking before and connecting later is defeated by DNS rebinding.
- Disable redirects or re-check every hop.

## Destructive operations on derived paths

- Before deleting or overwriting a path built from input: canonicalize it, require it to be
  inside an allowlisted root, at least one level below that root, and verify ownership
  (a marker file or a database record), not just existence.

## Rate limiting and abuse

- Limit per identity and per IP on auth, signup, password reset and expensive endpoints.
- Use a shared store (Redis or equivalent) — per-instance counters are bypassed by load
  balancing.

## Supply chain

- Before adding a dependency: maintenance, install scripts, transitive size, known advisories.
- Triage advisories by **reachability**: is the vulnerable function actually called?
- Never `audit fix --force`; bump deliberately, one package per change, review the lockfile diff.

## Personal data

- Collect the minimum; treat personal data as a liability with a retention period.
- Never put personal data in URLs, analytics events or logs without a documented reason.

## LLM output

- Treat model output as untrusted input: validate it against a schema before acting on it,
  never pass it to a shell, query or `eval`, and require confirmation for side effects it
  proposes.
