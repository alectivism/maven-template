---
description: Quick checkpoint without ending session
---

# /update - Quick Context Checkpoint

Lightweight save without ending the session. Use frequently to preserve context.

## Instructions

### 1. Identify What Changed
Quickly scan the recent conversation for:
- Topics worked on
- Decisions made
- Files created/modified
- Any state changes needed

Keep it brief. No full summary needed.

### 2. Append to Session Log
Get today's date: `date +%Y-%m-%d`

Append to `sessions/{TODAY}.md`:
```markdown
## Update: {TIME}
- {what was worked on, 1-3 bullets}
```

If file doesn't exist, create with header: `# Session Log: {TODAY}`

### 3. Update State (if needed)
Only update `state/current.md` if something actually changed:
- New open thread
- Completed item
- Changed priority
- New task discovered

Skip if nothing material changed.

### 4. Confirm (minimal)
One line: "Checkpointed: {brief description}"

No summary. No "next actions" list. Just confirm the save.
