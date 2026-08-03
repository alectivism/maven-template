---
name: handoff
description: Keep an append-only HANDOFF.md log so long-running work survives a closed session, a lost context, or a handoff to someone else. Use when starting work that will span multiple sessions, before a risky or hard-to-undo step, when a conversation is getting long, when the user says "pick this up later" or "write this down", or when resuming a project that already has a HANDOFF.md. Not for tasks that finish in one sitting.
---

# Handoff

A written record of what was decided and why, saved to disk **as you go** rather than summarized at the end.

The problem this solves: a long conversation ends unexpectedly (closed window, hit a limit, context ran out) and everything MAVEN worked out is gone, because the only record was the chat itself. A summary written at the end doesn't help, because the sessions that need it most are the ones that never got an end.

## When to write an entry

Write **before** doing the thing, not after:

- Choosing an approach that later work depends on
- Anything hard to undo (sending, publishing, deleting, overwriting)
- Starting something long or expensive
- Learning something that took real effort to figure out
- Wrapping up for the day

Also write when something **fails**. Knowing which approach already didn't work is as valuable as knowing which one did, and it stops the next session repeating it.

## Where it lives

`HANDOFF.md` in the project folder. One per project, not one per conversation.

If the folder is shared with other people, ask once whether the log should be shared too, then stop asking.

## Format

```markdown
# Handoff: <project>

**Goal:** <what finished looks like, in a sentence or two>

**Status:** <one line: where things stand right now>

---

## Current state
<Rewritten each time. What exists, what works, what's half-done.
Under 15 lines. This is orientation, not history.>

## Next steps
<Rewritten each time. Ordered and specific enough for someone with no
memory of the conversation. "Fix the deck" is not a next step.
"Slide 4 chart uses FY25 numbers, swap to FY26" is.>

## Open questions
<Waiting on a person, a decision, or information. Delete when answered.>

---

## Decision log
<APPEND ONLY. Never edit or delete an entry. Newest at the bottom.>

### 2026-08-03 14:22 — <short title>
**Decision:** <what was chosen>
**Why:** <the reason, including what was rejected>
**Evidence:** <what was actually checked. "Assumed" and "reported by X"
are valid answers; label them honestly rather than dressing them up.>
**Reversible:** <yes/no, and what undoing it would cost>

### 2026-08-03 15:05 — <short title> [DIDN'T WORK]
**Tried:** <the approach>
**Result:** <how it failed, specifically>
**Don't retry unless:** <what would have to change>
```

## Workflow

1. **Look for it first.** Check for `HANDOFF.md` before starting. If it exists, read it and treat past decisions as settled context. Don't quietly re-open one; if you think a past decision was wrong, say so out loud and explain why.
2. **Append as you go.** Newest entries at the bottom. Never rewrite or delete old ones, even wrong ones: a wrong decision plus its correction is exactly the record that stops the mistake happening a third time.
3. **Rewrite the top, grow the bottom.** Current state, Next steps, and Open questions get replaced each update. The decision log only ever grows.
4. **Give the user the file path** when you finish an update.

## Rules

- **Say whether you observed it or were told it.** Every entry distinguishes what was checked firsthand from what something else claimed. See `.claude/rules/verification.md`.
- **Write it before, not after.** An entry composed afterward is a summary, and it inherits everything the session already got wrong. Writing first means the reasoning survives even if the work doesn't.
- **Self-contained.** Someone reading only this file, with no chat history, should be able to continue. Use full file paths, full commands, and spell out acronyms once.
- **Don't duplicate what's already recorded.** Facts you could get from the files themselves don't belong here. This holds what they can't: why a path was chosen, and what was already tried.
- **Don't let it become a diary.** Past roughly 60 entries the project is either finished or the file is being misused. Archive it and start fresh, carrying forward only the decisions still in force.
