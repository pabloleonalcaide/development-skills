---
name: grilling
description: Grill the user relentlessly about a plan or design until shared understanding — interview one decision at a time, no code until confirmed. Use when the user wants to stress-test a plan or design before building, or uses any 'grill' trigger phrase.
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

**Open with your hypothesis.** Before the first question, state in two lines what you think I want and how sure you are, so I can correct the premise before we spend ten questions on it:

```
HYPOTHESIS: <what you think the outcome is, in one sentence>
CONFIDENCE: ~N% — missing: <the biggest unknowns>
```

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

If a *fact* can be found in the codebase, look it up. The *decisions* are mine — put each one to me and wait.

**Stop when you can predict me.** The grilling is done when you could predict my answers to the next three questions you would ask. Until then, keep going; once there, stop — more questions are noise.

**Close with a restate** and let me correct it:

```
Outcome:      <what will exist when this is done>
User:         <who it is for>
Why now:      <the trigger>
Success:      <how we will know it worked — observable>
Constraint:   <the hard limits>
Out of scope: <what we deliberately won't do>
```

Do not enact the plan until I confirm we have reached a shared understanding.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll ask all the questions at once to save time" | Batched questions get shallow answers and hide dependencies between decisions. |
| "I can decide this one myself" | If it is a decision, not a fact in the code, it's mine. Recommend, then ask. |
| "We've covered enough" | If you can't predict my next three answers, we haven't. |

## Red Flags

- A question whose answer was findable in the code.
- A question without a recommended answer.
- Code or files written before I confirmed the restate.
- The restate has no "Out of scope" line.
