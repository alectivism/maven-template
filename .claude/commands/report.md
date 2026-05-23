---
description: Generate a weekly report of your work
---

# /report - Weekly Report

Generate a summary of what you accomplished this week.

## Instructions

### 1. Gather the Data

Read the session logs from this week:
- Run `date +%Y-%m-%d` to get today's date
- Read session files from `sessions/` for the past 7 days
- Also read `state/current.md` for context on priorities
- Read `state/goals.md` to connect work to goals

### 2. Compile the Report

Create a report with these sections:

```markdown
# Weekly Report: {Week of DATE}

## Highlights
- Top 3-5 accomplishments this week
- Keep it concise, focus on outcomes not activities

## Work Completed
- Organized by project or goal area
- Include specific deliverables, decisions made, problems solved

## In Progress
- What's actively being worked on
- Expected completion or next steps

## Blockers / Needs Attention
- Anything stuck or waiting on others
- Decisions needed

## Next Week
- Top priorities for the coming week
- Carries forward from open threads

## Goals Progress
- Quick update on progress toward annual goals (from state/goals.md)
- Note any goals that got attention this week
```

### 3. Save the Report

Save to `reports/YYYY-MM-DD.md` using today's date.

### 4. Offer Next Steps

Ask: "Want me to copy this somewhere, share it, or adjust the format?"

Common follow-ups:
- Copy to clipboard for pasting into Slack/email
- Adjust tone (more formal for managers, casual for team)
- Focus on specific projects or goals
