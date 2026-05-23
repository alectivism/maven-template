---
description: Pull the latest MAVEN updates (new skills, context, commands)
---

# Update MAVEN

Pull the latest updates from the MAVEN GitHub repository.

## What Gets Updated
- `.claude/rules/` — MMA org context, brand guidelines, system rules
- `.claude/skills/` — New and improved skills
- `.claude/commands/` — Slash commands
- `skills/` — Core session management skills

## What's Never Touched (yours)
- `CLAUDE.md` — Your personal config
- `state/` — Your priorities and goals
- `sessions/` — Your session logs
- `reports/` — Your reports
- `.env` — Your API keys

## Process

1. Check if there are local changes to tracked files
2. If so, stash them temporarily
3. Pull latest from GitHub
4. Restore any stashed changes
5. Report what was updated

Run this:
```bash
cd ~/maven
git stash 2>/dev/null
git pull origin main
git stash pop 2>/dev/null
```

Show a summary of what changed (new files, updated files).

If there are merge conflicts, explain them clearly and help resolve.
