---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up. Use when the user wants to hand off, continue in a new session, or save the session state for later.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS - not the current workspace.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Include an **"Approvals"** section: for every plan, blueprint or destructive action discussed, state whether it was approved, by whom, and the exact scope approved (e.g. "blueprint approved — authorizes tests, code, commits, push and PR for steps 1-4; step 5 not approved"). If nothing was approved, say so.

**An approval is never inherited from a previous session unless a durable artifact records it** — the handoff doc, the tracker task or the plan file. The next agent must re-ask for anything this section does not cover.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
