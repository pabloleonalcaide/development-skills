---
name: security-hardening
description: Threat-model a change and harden it before it ships — trust boundaries, authn/authz, input validation, secrets, SSRF, destructive operations, rate limits and supply chain. Use when a change touches authentication or authorization, payments, user or external input, webhooks, file paths, outbound requests, secrets or new dependencies, or when the user asks for a security review of a design. Invoked by /develop when the blueprint declares security impact.
---

# Security hardening

Security is a design property, not a review step: decide where trust ends **before** writing the
code that crosses that line. This skill runs at design time (phase B/C of `develop`) and leaves a
checklist that the hardening reviewers verify against the diff.

## When NOT to use

- Dependency CVE alerts — that is a dependency-maintenance task, not a design review.
- Changes with no new input, output, permission or dependency (pure refactors, copy changes).
- As a substitute for a post-hoc diff review tool: this skill shapes the design; a diff review
  checks the result.

## Process

1. **Map the trust boundaries.** List every place data crosses from a less-trusted to a
   more-trusted zone: HTTP request → handler, webhook → handler, queue message → consumer, file
   upload → storage, **LLM output → code or tool call**, another process's arguments or env →
   your logic. Rule: *trust follows who wrote a value, not which channel delivered it* — a value
   read from your own database that a user wrote is still user input.
2. **STRIDE each boundary** — one row per boundary, only the threats that apply:

   | Boundary | Spoofing | Tampering | Repudiation | Info disclosure | DoS | Elevation |
   |---|---|---|---|---|---|---|

3. **Write the abuse cases as the first tests.** For each real threat, a test that plays the
   attacker: another tenant's id, a forged signature, a `../` path, an oversized payload, a
   replayed request. These go through the same seams as the feature tests.
4. **Classify the actions in the change** into three tiers and put them in the blueprint:
   - **Always** — validate at the boundary, check authorization on the resource (not just
     authentication), parameterize queries, encode output, log security events without secrets.
   - **Ask first** — new dependency, new outbound host, new permission or role, schema change on
     auth data, disabling a check "temporarily".
   - **Never** — secrets in code/logs/URLs, `eval` on external input, trusting client-side
     checks, disabling TLS verification, `audit fix --force`.
5. **Apply the controls.** Open [REFERENCE.md](REFERENCE.md) at the section you need when you
   reach that code, not before.
6. **Hand the checklist to hardening.** The Verification list below goes into the *Standards*
   reviewer's input.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's an internal endpoint" | Internal networks get breached; SSRF turns every internal endpoint into an external one. |
| "The frontend already validates it" | The frontend is the attacker's code. Validate at the server boundary. |
| "The user is authenticated, that's enough" | Authentication says who; authorization says whether *this* user may touch *this* resource. IDOR lives in the gap. |
| "I'll remove the secret from git later" | Once pushed it is leaked. Rotate first, then purge history. |
| "It's just a dev dependency" | Install scripts run on every machine and CI runner that installs it. |

## Red Flags

- A handler reads an id from the request and loads the resource without checking ownership.
- A string concatenated into a query, shell command, path or URL.
- A webhook handler that does not verify the signature before parsing.
- Secrets, tokens or personal data in a log line, error message or URL.
- A `catch` that swallows an authorization error and continues.
- A new dependency added without checking its install scripts and maintenance.

## Verification

- [ ] Every trust boundary in the change is listed with its applicable threats
- [ ] Each real threat has an abuse-case test that fails without the control
- [ ] Authorization is checked on the resource at every new or changed entry point
- [ ] No secret or personal data in code, logs, errors or URLs (grep the diff)
- [ ] Any "Ask first" action was asked and the answer recorded in the blueprint
