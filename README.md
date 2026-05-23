# MAVEN — An AI Chief of Staff for Claude Code

**MAVEN** = Agentic Virtual Executive Navigator

An opinionated Claude Code template that gives you an AI chief of staff with:

- **Session continuity** — daily briefings, end-of-day checkpoints, goals tracked across sessions
- **Templated org context** — fill in your team, brand, programs once and Claude knows your world forever after
- **Power-ups beyond Sterling's MARVIN template** — a real statusline with cost/pace tracking, multi-agent guidance, expanded MCP recommendations, and reusable skills

Inspired by Sterling Chin's [MARVIN template](https://github.com/SterlingChin/marvin-template). This goes further: org-aware out of the box, more power-ups for serious Claude Code users, and built around real production use at a 90-person global organization.

---

## Quick start

1. Clone:
   ```bash
   git clone https://github.com/alectivism/maven-template.git ~/maven
   cd ~/maven
   ```

2. Open in Claude Code:
   ```bash
   claude
   ```

3. Run onboarding:
   > `/onboard`

That walks you through your profile, your org context, brand rules, and optional integrations. About 10-15 minutes for the first pass.

---

## What you get

### Daily workflow

| Command | What it does |
|---|---|
| `/start` | Daily briefing: priorities, deadlines, progress, open threads |
| `/end` | End-of-day checkpoint. Save state for tomorrow. |
| `/update` | Mid-day checkpoint without ending |
| `/report` | Weekly summary |
| `/commit` | Review + commit git changes |
| `/health` | Check workspace + integration health |
| `/sync` | Pull updates from this template into your workspace |
| `/help` | Show every command |
| `/onboard` | First-time (or repeat) setup walkthrough |
| `/learn` | Capture a learning to memory |

### Org context (templated, fillable)

Two files in `.claude/rules/`:
- `org-context.md` — your org, departments, leaders, programs, acronyms
- `org-brand.md` — naming rules, voice, banned words, boilerplate

Fill these once via `/onboard`. Claude reads them every conversation.

### Power-ups

- **Custom statusline** (`.claude/scripts/statusline.sh`) — shows current model, effort level, context-window usage, session cost burn-rate vs cap, weekly cost burn-rate, with reset countdown for both. Calibrated for Claude Code on a subscription plan; see the script's header for how to recalibrate.
- **Multi-agent docs** (`docs/multi-agent.md`) — subagents, worktrees, teams, background commands, cron. Five patterns and when to use each.
- **MCP recommendations** (`docs/mcp-recommendations.md`) — opinionated list of MCP servers worth adding beyond the core set: Parallel Search, Perplexity, Firecrawl, Apify, Granola, Context7, Playwright, and more.
- **Experimental settings** — multi-agent teams + custom autocompact threshold pre-configured in `.claude/settings.json`.

### Skills

Reusable skills under `skills/`:
- `commit/` — Git commit drafting with standardized message format
- `content-shipped/` — Track what you publish across channels
- `daily-briefing/` — How `/start` builds your morning briefing
- `end/` — How `/end` checkpoints your day
- `skill-creator/` — Create new skills via prompt
- `update/` — How `/update` does mid-day saves

Plus generic skills like `research`, `social-post`, `zapier-workflow-builder` under `.claude/skills/`.

### Integrations

Drop in any of these from `.marvin/integrations/`:
- Google Workspace (Gmail, Calendar, Drive)
- Microsoft 365 (Outlook, Calendar, OneDrive, Teams)
- Atlassian (Jira, Confluence)
- Slack
- Linear
- Notion
- Telegram
- Parallel Search

Each has its own setup doc inside.

---

## Statusline (the most-asked-about power-up)

The statusline shows below your input box and looks like:

```
Claude Opus 4.7 (1M) | high | 🧠 142k 14% | Session 🟢 31% · 2h17m | Week 🟡 67% · 3d4h
```

That's: **model | effort | context-usage | session-cost-pace · session-reset | weekly-cost-pace · weekly-reset**

Calibrated against `ccusage` for a Claude Team subscription. Recalibrate by snapshotting `ccusage` cost AND Anthropic's % at the same moment, then updating `SESSION_COST_CENTS` and `WEEKLY_COST_CENTS` at the top of the script.

To install:

```json
// in ~/.claude/settings.json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/<you>/maven/.claude/scripts/statusline.sh"
  }
}
```

Or run `/onboard` and accept when prompted.

---

## Architecture

MAVEN separates the **template** (this repo) from your **workspace** (your clone):

```
~/maven/                    Your workspace (yours to edit)
├── CLAUDE.md               Your personal profile + preferences
├── .claude/
│   ├── commands/           Slash commands (start, end, onboard, etc.)
│   ├── rules/              org-context, org-brand, safety, system
│   ├── skills/             Reusable skills
│   └── scripts/            Statusline + helpers
├── skills/                 Top-level reusable skills
├── state/                  Current priorities + goals (Claude reads/writes)
├── sessions/               Daily session checkpoints
├── reports/                Weekly + custom reports
└── docs/                   Multi-agent, MCP recommendations, more
```

Run `/sync` to pull new features from the template into your workspace without losing your data.

---

## Differences from Sterling's MARVIN template

| | Sterling's MARVIN | MAVEN |
|---|---|---|
| Org context | Personal profile only | Templated org context (departments, brand, acronyms) |
| Onboarding | Inline guidance | Dedicated `/onboard` command with interactive walkthrough |
| Statusline | Not included | Full ccusage-calibrated cost + pace + reset tracker |
| Multi-agent docs | Not included | 5 patterns documented |
| MCP recommendations | Not opinionated | Curated list with rationale |
| Settings | Defaults | Multi-agent teams enabled, higher autocompact threshold |
| Default skills | Generic chief-of-staff | + research, social-post, content-shipped, zapier-builder |

Both are MIT-licensed. Use either, fork either, mix them.

---

## Credit

- Original MARVIN template by [Sterling Chin](https://github.com/SterlingChin/marvin-template) — the architectural foundation.
- MAVEN extensions by [Alec Foster](https://alecfoster.com) — built around real use at the Marketing + Media Alliance.

License: MIT.
