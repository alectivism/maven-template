---
description: Save a correction or preference as a persistent rule
---

# Learn from Correction

Review the recent conversation to identify what was corrected, clarified, or requested as a preference. Save it as a persistent rule so it applies to all future sessions.

## Process

1. Look at the last few messages for corrections, preferences, or "always/never" instructions
2. Summarize the learning as a concise rule (one line if possible)
3. Read `.claude/rules/learned.md` (create if it doesn't exist)
4. Check for duplicates or contradictions with existing rules
5. Append the new rule under the appropriate category
6. Confirm what was saved

## Format for learned.md

```markdown
# Learned Rules

Rules captured from corrections and preferences during sessions.

## Communication
- [rules about tone, formatting, recipients, etc.]

## Content
- [rules about writing style, templates, naming, etc.]

## Process
- [rules about workflows, approvals, tool preferences, etc.]

## Data
- [rules about what to include/exclude, sources, etc.]
```

## Guidelines

- Keep rules concise and actionable
- If the new rule contradicts an existing one, replace the old one
- Don't save one-time instructions — only save things that should persist
- If unclear what to save, ask
