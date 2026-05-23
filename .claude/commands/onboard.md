---
description: First-time setup walkthrough — fill in your profile, org context, brand rules, and optional integrations.
---

# /onboard - First-Time Setup

Walk the user through MAVEN setup interactively. Goal: by the end, MAVEN knows who they are, where they work, and how to work with them.

## Instructions

### 1. Greet + Detect State

```bash
date +%Y-%m-%d
```

Read these to determine what's already filled in:
- `CLAUDE.md` — user profile section
- `.claude/rules/org-context.md` — looks for `{{ORG_NAME}}` etc. placeholders
- `.claude/rules/org-brand.md` — same

If most placeholders are gone, skip ahead and just confirm what's set. If most are present, walk the user through every step.

### 2. Personal Profile (CLAUDE.md)

Ask one question at a time. Use AskUserQuestion when the question has 2-4 clear answer types; otherwise free text.

Required:
- **Name** — what should MAVEN call you?
- **Role / title** — what's your job?
- **Org** — where do you work?
- **Primary tools** — what does your day actually run on? (e.g., Slack, Outlook, Asana, Notion, Linear, etc.)

Optional:
- **Communication style** — how do you want MAVEN to write? (Terse / Conversational / Formal)
- **Working hours / time zone**

After collecting, write the answers into `CLAUDE.md` under "Your Profile" — replace the placeholder lines, don't append.

### 3. Org Context (.claude/rules/org-context.md)

This is the part most people skip and then regret. Walk through it carefully.

Required to fill placeholders:
- `{{ORG_NAME}}` — full org name
- `{{ORG_ONE_LINER}}` — 10-20 word description
- `{{HEADCOUNT}}` — number of employees
- `{{LEADER_NAME}}` — CEO or founder

Recommended (offer to skip with one-line defaults):
- Departments table — at least 3 rows of "Department | Key People | Focus"
- Programs/products — at least 3 bullets
- Internal acronyms — even 1-2 helps a lot

After filling, set `{{SETUP_STATUS}}` to `complete` and `{{LAST_UPDATED}}` to today's date.

### 4. Brand Rules (.claude/rules/org-brand.md)

Often quick if the user has a brand guide. Otherwise prompt for minimum viable:
- `{{ORG_FULL_NAME}}` and `{{ORG_ABBREV}}`
- `{{VOICE_DESCRIPTION}}` — 2-4 sentences
- `{{BANNED_WORDS}}` — even just "buzzwords, jargon" is fine

Set `{{SETUP_STATUS}}` to `complete`.

### 5. Optional Integrations

For each, ask: "Do you use [tool]? If yes, here's how to connect it." Direct them to `.marvin/integrations/<tool>/` for setup instructions.

Walk through in this order, skipping ones they don't use:
1. **Google Workspace** OR **Microsoft 365** (everyone has one)
2. **Slack** (most knowledge-work orgs)
3. **Notion** (if used)
4. **Asana / Linear / Jira** (whichever applies)
5. **Granola / Fireflies** (if they take meetings)
6. **Parallel Search** (free; recommend it)

Don't try to do all of them in one session. Surface the highest-priority ones first.

### 6. Optional MCP Recommendations

Read `.marvin/integrations/RECOMMENDED-MCPS.md`. Ask if they want to set up any of the optional MCPs (Apify, Firecrawl, Granola, Context7, Perplexity, etc.). For each, explain in one sentence what it unlocks.

### 7. Custom Statusline

Ask: "Want to install Alec's enhanced statusline (shows current model, agent count, session tokens, working dir)? It's optional."

If yes: read `.marvin/setup-statusline.sh` and walk them through. Or copy `.claude/statusline.sh` into their global Claude Code settings.

### 8. Wrap Up

Summarize what was set up. Tell them:
- "Run `/start` tomorrow morning for a daily briefing."
- "Run `/end` at end of day to checkpoint."
- "Run `/help` to see every command."

Save a setup-complete marker:

```bash
mkdir -p state && echo "$(date +%Y-%m-%d)" > state/onboarded.txt
```

## Notes

- This command is idempotent: the user can re-run `/onboard` to update any section. Skip questions whose answers are already filled in.
- Never write the user's actual passwords or API keys to any file. If a step requires a key, instruct them to put it in `.env` (never committed) and reference it from env-var.
