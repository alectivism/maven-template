---
name: maven
description: Start a MAVEN session with context loading and daily briefing. Use when the user says "/maven", "/start", "start session", "good morning", "let's get started", or begins a new work session.
allowed-tools:
  - Read
  - Glob
  - Grep
  - mcp__ms365__outlook_calendar_search
  - mcp__ms365__outlook_email_search
  - mcp__asana__asana_search_tasks
---

# Start MAVEN Session

## Startup Sequence

### 1. Check Date
Determine today's date.

### 2. Load Context
Read these files (skip any that don't exist):
- `state/current.md` — active priorities and open threads
- `state/goals.md` — current goals
- Today's session log: `sessions/YYYY-MM-DD.md`
- If no session log for today, read the most recent one in `sessions/`

### 3. Check Context Freshness
- If `state/current.md` hasn't been updated in 3+ days, flag it
- Note any overdue items or deadlines

### 4. Deliver Briefing

**Format:**
```
## MAVEN Briefing — [Day of Week], [Date]

### Top Priorities
1. [Priority from current.md]
2. [Priority]
3. [Priority]

### Today's Calendar
[Check Outlook calendar for today's events if ms365 is available]

### Alerts
- [Overdue items]
- [Upcoming deadlines within 3 days]
- [Stale context warnings]

### Open Threads
- [Active threads needing attention]
```

### 5. Offer Direction
End with: "What would you like to focus on?"

## Guidelines
- Keep the briefing concise — under 30 seconds to read
- Highlight blockers or urgent items first
- Don't read back the entire state file — synthesize
- If this is the first session ever, trigger onboarding flow instead
