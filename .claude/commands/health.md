---
description: Run a diagnostic check on MAVEN setup and integrations
---

# MAVEN Health Check

Run a full diagnostic of this MAVEN instance. Check each item below and report results in a summary table.

## 1. Required Files

Check that these files exist and are properly configured:

| File | Check |
|------|-------|
| `CLAUDE.md` | Exists AND has been personalized (not still showing `[Your name]` or `[Your role]` placeholders) |
| `state/current.md` | Exists |
| `state/goals.md` | Exists |
| `.env` | Exists (even if empty) |

Use the Read tool to check each file. For CLAUDE.md, read it and verify the user has filled in their name and role.

## 2. Core Integrations

Test each integration with a lightweight operation. Do NOT send any messages or modify any data — read-only operations only.

| Integration | Test | Tool |
|-------------|------|------|
| **MS365** (Outlook) | List 1 recent email OR check today's calendar | `mcp__ms365__list-mail-messages` or `mcp__ms365__get-calendar-view` |
| **Slack** | List channels or check connection | Slack MCP |
| **Asana** | List workspaces | `mcp__asana__asana_list_workspaces` |
| **Parallel Search** | Run a trivial web search like "MMA marketing" | `mcp__parallel-search__web_search_preview` |

## 3. Optional Integrations

Only test these if they appear to be configured (check available tools). Skip any that aren't installed.

| Integration | Test |
|-------------|------|
| **Salesforce** | List a record or check connection |
| **OpenAI** | Simple prompt test |
| **Gemini** | Simple prompt test |
| **ElevenLabs** | Check connection |
| **Context7** | Resolve a library |
| **Exa** | Simple search |
| **Fireflies** | Check connection |

## 4. Report Results

Present a single summary table with all results:

```
MAVEN Health Check
==================

Required Files
| Item              | Status | Notes |
|-------------------|--------|-------|
| CLAUDE.md         | ...    | ...   |
| state/current.md  | ...    | ...   |
| state/goals.md    | ...    | ...   |
| .env              | ...    | ...   |

Core Integrations
| Integration      | Status | Notes |
|------------------|--------|-------|
| MS365 (Outlook)  | ...    | ...   |
| Slack            | ...    | ...   |
| Asana            | ...    | ...   |
| Parallel Search  | ...    | ...   |

Optional Integrations
| Integration      | Status | Notes |
|------------------|--------|-------|
| ...              | ...    | ...   |
```

Use these status indicators:
- **Connected** — integration responded successfully
- **Configured** — file exists and is set up correctly
- **Not connected** — integration failed or timed out
- **Not configured** — file missing or still has placeholders
- **Issue detected** — partially working, explain the problem

## 5. Fixes

If anything failed, list the fix for each issue. Common fixes:

| Problem | Fix |
|---------|-----|
| MS365 not connected | Run `./.marvin/integrations/ms365/setup.sh` in your terminal |
| CLAUDE.md not personalized | Open CLAUDE.md and fill in your name, role, and department |
| .env missing | Create a `.env` file in the MAVEN root folder (can be empty to start) |
| state/ files missing | Run `/maven` to initialize your session — it will create them |
| Slack not connected | Ask Alec Foster for Slack MCP setup instructions |
| Asana not connected | Ask Alec Foster for Asana MCP setup instructions |

End with a one-line summary: "X of Y checks passed. [Ready to go / Fix the items above to get started.]"
