# Claude Code: Setup, Architecture, and Best Practices

**Author:** Alec Foster, MMA
**Last updated:** 2026-04-15

This document captures how I've configured Claude Code as a comprehensive AI operating system for both organizational and personal work. It covers architecture decisions, MCP integrations, multi-model orchestration, skill systems, automation patterns, and lessons learned over four months of intensive daily use.

---

## Table of Contents

1. [Philosophy](#philosophy)
2. [Architecture: Three Layers](#architecture-three-layers)
3. [Configuration Structure](#configuration-structure)
4. [MCP Server Stack](#mcp-server-stack)
5. [Adaptive MCP Profiles](#adaptive-mcp-profiles)
6. [Multi-Model Orchestration](#multi-model-orchestration)
7. [Skills System](#skills-system)
8. [Slash Commands](#slash-commands)
9. [Subagents and Parallel Dispatch](#subagents-and-parallel-dispatch)
10. [Plugins](#plugins)
11. [Hooks and Automation](#hooks-and-automation)
12. [Memory System](#memory-system)
13. [Security and Permissions](#security-and-permissions)
14. [Project-Specific Setups](#project-specific-setups)
15. [Content Pipeline](#content-pipeline)
16. [Scraping Techniques](#scraping-techniques)
17. [Workflow Patterns](#workflow-patterns)
18. [MARVIN: The AI Chief of Staff](#marvin-the-ai-chief-of-staff)
19. [Deployment to Staff](#deployment-to-staff)
20. [Key Lessons Learned](#key-lessons-learned)

---

## Philosophy

Claude Code is not a chatbot. It's a persistent, context-aware operating layer that sits between me and every tool I use: email, calendar, project management, web research, content creation, code, and automation. The goal is to never context-switch. Everything flows through one interface.

Core principles:

- **One interface for everything.** Email, Slack, Asana, SharePoint, research, drafting, coding, automation: all accessible from the same terminal session.
- **Context persists across sessions.** State files, memory, and session logs mean Claude picks up where we left off. No re-explaining.
- **Proactive, not reactive.** The system surfaces what I need before I ask. Session briefings, deadline awareness, open thread tracking.
- **Parallel by default.** Independent tasks run simultaneously via subagents. Research and writing happen in the same agent (never split them).
- **Multi-model, not single-model.** Claude orchestrates, but Gemini and GPT handle tasks where they're stronger: Google Search grounding, Reddit data, peer review, tiebreaking.

---

## Architecture: Three Layers

The system is organized into three tiers that serve different audiences:

```
MARVIN (Alec's personal instance)
  |
  |-- /sync-maven --> MAVEN (public template for Claude Code power users)
  |
  |-- manual sync --> MMA Plugin (skills only, for all staff via claude.ai web/mobile)
```

### Layer 1: MARVIN

My personal AI Chief of Staff. Full integration stack (30+ MCP servers), session management, persistent memory, goal tracking, content pipeline, multi-model CLI access, bypass-permissions mode. Lives at `~/marvin/`.

### Layer 2: MAVEN

A public GitHub template (`alectivism/MAVEN`) that any MMA staff member can install to get Claude Code with session management, MMA org context, brand guidelines, and all 20 MMA skills. No integrations bundled (staff add their own). Includes setup.sh for first-time install.

### Layer 3: MMA Plugin

A private GitHub repo (`alectivism/mma-plugin`) deployed via Claude Teams admin panel. Provides 20 MMA skills to all staff through claude.ai web and mobile, no installation required. Skills cover brand guidelines, writing style, org context, email drafting, content creation, research briefs, and more.

### Two-Branch Context Model

MARVIN's context includes operational details (SharePoint paths, Slack channel IDs, integration configs). Staff-facing versions (MAVEN, MMA Plugin) strip those details because staff don't have the same tools. When updating org context, changes propagate MARVIN-first, then outward with sensitive details removed.

---

## Configuration Structure

Claude Code configuration lives at two levels:

### Global (User-Level): `~/.claude/`

```
~/.claude/
  CLAUDE.md              # Communication style, safety rules, parallel dispatch prefs
  settings.json          # Plugins, permissions, hooks, effort level, feature flags
  .claude.json           # MCP server definitions (auto-generated)
  agents/                # 12 shared subagents (researcher, email-drafter, etc.)
  scripts/
    mcp-profile.sh       # SessionStart hook: adaptive MCP profile detection
    mcp-profiles.conf    # Directory-to-profile mapping overrides
  mcp-servers/           # Custom MCP server code
    dynalist/            # Dynalist API (Zod 3 pinned)
    openai/              # GPT-5.4 wrapper
    grok/                # Grok 4.20 via xAI API
    n8n-proxy.mjs        # n8n Cloud instance proxy
  skills/                # User-level skills (brand guidelines, writing style)
  projects/              # Per-project auto-memory directories
```

### Project-Level: `<repo>/.claude/`

Each project has its own CLAUDE.md and optional rules, skills, and commands:

```
~/marvin/.claude/
  rules/                 # Auto-loaded every session
    marvin-system.md     # Session workflow, commands, workspace structure
    mma-context.md       # Org structure, teams, programs, security rules
    mma-brand.md         # Naming, voice, program acronyms
    agent-routing.md     # When/how to spawn subagents, MCP tool selection
  skills/                # 22 on-demand MMA skills
  commands/              # 22 slash commands (/marvin, /end, /draft, etc.)
```

### Key Settings

```json
{
  "defaultMode": "bypassPermissions",
  "effortLevel": "medium",
  "autoDreamEnabled": true,
  "voiceEnabled": true,
  "skipDangerousModePermissionPrompt": true
}
```

- **bypassPermissions**: Trusted workspace. All tool calls execute without prompts except explicitly denied patterns.
- **effortLevel: medium**: Balanced token usage. Opus still runs, just more concise.
- **autoDreamEnabled**: Background memory consolidation between sessions.

---

## MCP Server Stack

31 MCP servers across five categories, plus CLI tools and claude.ai connectors.

### Communication and Productivity

| Tool | MCP Server | What It Does |
|------|-----------|--------------|
| Outlook | ms365 + claude.ai Microsoft 365 | Read/send email, calendar events, search, attachments |
| Slack | claude.ai Slack + standalone slack MCP | Read channels, search, send messages, create canvases |
| Asana | asana + claude.ai Asana | Create/update tasks, search projects, manage sections |
| Gmail | claude.ai Gmail + google-workspace | Read/draft emails (MMA via M365, personal via Google) |
| Granola | claude.ai Granola | Meeting transcripts (preferred over Fireflies) |
| Fireflies | fireflies | Legacy meeting transcripts, search, summaries |
| Notion | claude.ai Notion | Search, create/update pages, manage databases |

### Research and Content Discovery

| Tool | MCP Server | What It Does |
|------|-----------|--------------|
| Web Search | parallel-search (primary, free) | General web search and page content extraction |
| Semantic Search | exa | AI-powered semantic web search |
| AI Research | perplexity | Synthesized answers with citations, deep multi-source research |
| Web Scraping | firecrawl | JS-rendered scraping, batch scrape, site crawl/map |
| Platform Search | search1api | Reddit, X/Twitter, YouTube, news search (100 free credits) |
| LinkedIn | linkedin + apify-linkedin | Profile/company lookup, post history with engagement stats |

### Content Creation

| Tool | MCP Server | What It Does |
|------|-----------|--------------|
| Design | Canva | Create/export designs, brand kit access |
| Voice/Audio | elevenlabs | Text-to-speech, voice cloning, sound effects, music |
| Image/Video | gemini (generate_image, generate_video) | Gemini-powered image and video generation |

### Knowledge and Documents

| Tool | MCP Server | What It Does |
|------|-----------|--------------|
| SharePoint | ms365 + claude.ai Microsoft 365 | Search docs, browse folders, upload/download files |
| Library Docs | claude.ai Context7 | Live framework/library documentation lookup |
| Dynalist | dynalist (custom) | Read/edit outlines (personal knowledge management) |
| Google Drive | google-workspace | Drive, Docs, Sheets, Slides, Forms, Apps Script |
| Firebase/GCP Docs | google-dev-knowledge | Official Firebase, GCP, Android, Maps documentation |

### Development and Automation

| Tool | MCP Server | What It Does |
|------|-----------|--------------|
| n8n (live) | n8n-cloud | Create, execute, and update workflows on live instance |
| n8n (docs) | n8n-mcp | Node documentation, templates, workflow validation |
| Salesforce | salesforce (disabled by default) | Query records, run reports. Enabled on demand. |
| Task Master | taskmaster-ai | Break requirements into structured tasks with dependencies |
| Sequential Thinking | sequential-thinking | Structured reasoning scratchpad for complex problems |

### AI Models (via MCP)

| Model | MCP Server | Use For |
|-------|-----------|---------|
| Gemini 3.1 Pro | gemini (13 tools) | Google Search grounding, image/video gen, Reddit data |
| GPT-5.4 | openai (ask-openai) | Quick inline questions (API billing) |
| Grok 4.20 | grok (ask-grok) | Alternative perspectives, X/Twitter context |

### claude.ai Connectors (Remote)

Connected: Microsoft 365, Slack, Asana, Gmail, Granola, Notion, Context7

These work across all Claude surfaces (web, mobile, Claude Code) and require no local installation.

---

## Adaptive MCP Profiles

A SessionStart hook automatically detects the project type and adjusts behavior. This prevents irrelevant tools from cluttering the context.

### How It Works

1. On every session start, `~/.claude/scripts/mcp-profile.sh` runs
2. Checks `mcp-profiles.conf` for explicit directory-to-profile mappings
3. Falls back to auto-detection from file signatures (package.json, tsconfig.json, pyproject.toml, firebase.json, etc.)
4. Toggles plugins (context7, playwright) based on profile
5. Injects a system message so Claude immediately knows what profile is active

### Profiles

| Profile | Trigger | Behavior |
|---------|---------|----------|
| **mma** | MARVIN, MAVEN, MMA repos | Coding plugins off. claude.ai connectors prioritized for Slack, Asana, M365. |
| **coding** | package.json+tsconfig, pyproject.toml, firebase.json, Cargo.toml, go.mod | context7 and playwright plugins ON. MMA MCPs deprioritized. |
| **content** | Content pipeline directories | LinkedIn, Canva, Gemini image gen, Firecrawl, Perplexity prioritized. |
| **default** | Everything else | All MCPs available. Coding plugins off. |

### Configuration

Explicit overrides in `~/.claude/scripts/mcp-profiles.conf`:

```
# MMA org work
/Users/alec/marvin=mma
/Users/alec/mma-plugin=mma
/Users/alec/mma-maven-template=mma

# Software development
/Users/alec/arcpush=coding
/Users/alec/mma-rag-prototype=coding
/Users/alec/rep-radar=coding
```

New projects with standard file signatures are recognized automatically without configuration.

---

## Multi-Model Orchestration

Claude Code orchestrates three AI models, all on unlimited subscriptions. This is a force multiplier: different models have different strengths, and the cost of querying all three is zero.

### Three Tiers of Access

**Tier 1: MCP Tools** (structured, low-overhead, inline)

- `gemini_chat`: Google Search grounding, current events, Reddit data
- `ask-openai`: Quick GPT-5.4 questions (note: API billing, prefer Codex CLI)
- `ask-grok`: xAI perspective, X/Twitter context
- `generate_image` / `generate_video`: Gemini-powered media generation

**Tier 2: CLI Tools** (file-heavy, large-context, independent work)

CLI models read files directly, think independently, and return only the summary. This saves Claude's context window from exploration noise.

```bash
# Gemini CLI: file analysis, research synthesis
gemini -p "summarize these docs" @doc1.md @doc2.md @doc3.md

# Codex CLI: peer review, codebase scans
codex exec --full-auto --cd /path "review this code for bugs and issues"
```

**Tier 3: Combined** (multi-model workshopping)

Run the same prompt through all three models, synthesize the best ideas. Particularly useful for:
- Strategy decisions (each model brings different reasoning patterns)
- Content drafting (pick the strongest voice)
- Tiebreaking (when two models disagree, the third breaks the tie)

### Routing Rules

- **Prefer CLI over MCP for GPT:** Codex CLI is free (subscription), ask-openai MCP costs per call
- **Prefer CLI for file-heavy work:** CLI reads files directly; Claude only sees the summary
- **Use MCP for structured calls:** Image generation, quick inline questions, tool-specific operations
- **Use Gemini for Reddit:** Google's data deal gives Gemini the best Reddit coverage of any AI model
- **Claude's WebSearch is blocked from reddit.com:** Use parallel-search with site:reddit.com, Gemini, or Firecrawl instead

---

## Skills System

Skills are on-demand knowledge modules that load into context only when needed. This keeps the base context lean while making deep domain knowledge available.

### MMA Skills (22 skills in `~/marvin/.claude/skills/`)

| Skill | Purpose |
|-------|---------|
| mma-org-context | Org structure, teams, think tanks, labs, events, membership |
| mma-brand-guidelines | Colors, fonts, logos, document formatting, boilerplate |
| mma-writing-style | Tone, voice, naming conventions, formatting standards |
| mma-pptx-builder | PowerPoint deck construction with official template |
| email-draft | Professional emails in MMA's brand voice |
| social-post | LinkedIn posts for MMA channels |
| press-release | Wire-ready press releases |
| content-draft | Blog posts, articles, one-pagers, marketing collateral |
| case-study | Case studies from lab results and member experiences |
| research-brief | Structured research briefs for different audiences |
| lab-summary | MMA Future Lab result summaries |
| meeting-followup | Segmented follow-up emails after meetings |
| member-comms | Onboarding, renewal, engagement communications |
| event-promo | Promotional content for MMA events |
| content-strategy | Editorial calendars, content pillars, distribution plans |
| launch-strategy | Go-to-market planning for programs and initiatives |
| slack-summary | Slack channel activity summaries |
| sharepoint-find | SharePoint document navigation |
| asana-task | Asana task management |
| briefing-prep | Meeting preparation with attendee research |
| research | Web research with structured findings |
| zapier-workflow-builder | Zapier workflow design and troubleshooting |

### Session Skills (8 skills in `~/marvin/skills/`)

Handle session lifecycle: start, end, update, commit, report, daily briefing, content publishing, skill creation.

### How Skills Load

Skills are not always in context. They load on demand when:
1. A matching slash command triggers them
2. The skill's description matches the current task
3. A plugin's trigger conditions are met

This is critical for context management. 22 MMA skills would consume enormous context if always loaded. On-demand loading keeps the working context focused.

---

## Slash Commands

22 commands registered in `~/marvin/.claude/commands/`:

### Session Management
| Command | Action |
|---------|--------|
| `/marvin` or `/start` | Start session: git pull, load state, present briefing |
| `/end` | End session: summarize, save log, update state, git push |
| `/update` | Quick mid-session checkpoint without ending |
| `/commit` | Review changes and create clean git commits |
| `/report` | Generate weekly summary of work done |
| `/help` | Show all commands and integration status |
| `/health` | Run diagnostic check on setup and integrations |
| `/code` | Open MARVIN in IDE (Cursor, VS Code) |

### Content Pipeline
| Command | Action |
|---------|--------|
| `/draft` | Topic to research to post + infographic + metadata |
| `/image` | Generate or regenerate infographic for a post |
| `/footer` | Composite branded footer onto an infographic |
| `/publish` | Prepare post for LinkedIn (clipboard + folder open) |
| `/review` | Review and refine a draft post |
| `/triage` | Triage content intake, rank topics for drafting |
| `/queue` | Show content pipeline queue and post status |
| `/capture` | Capture a content idea into the pipeline |

### System
| Command | Action |
|---------|--------|
| `/learn` | Save a correction or preference as a persistent rule |
| `/sync` | Check Sterling's MARVIN template for updates |
| `/sync-maven` | Push MARVIN skills and rules to the MAVEN template |
| `/sync-plugins` | Pull upstream updates for plugin mirrors |
| `/briefing` | Generate audio briefing from emails and Slack DMs |

---

## Subagents and Parallel Dispatch

### When to Spawn Subagents

Spawn when the task generates intermediate noise that would bloat the main context:
- 3+ web searches (research noise)
- 500+ word content that needs research (research + writing combined)
- 3+ integration API calls (tool-call noise)
- Genuinely independent subtask where only the summary matters

### When NOT to Spawn

Handle directly when:
- Simple tasks (1-2 searches, short content, single API call)
- Multiple user decision points needed
- Editing or revising existing content
- Quick lookups or fact-checking

### Key Principle: Never Split Research from Writing

The agent that gathers information must also produce the output. Splitting research and writing creates a "telephone game" that degrades information quality. A content-writer subagent researches AND drafts. A researcher subagent gathers AND synthesizes.

### Model Routing: Sonnet vs Opus

**Default: sonnet for all subagents.** This is a deliberate token-saving strategy. Sonnet is fast, cheap, and good enough for the vast majority of delegated work. Every custom agent definition in `~/.claude/agents/` has `model: sonnet` in its frontmatter.

**Use opus only when the task requires:**
- Deep reasoning or complex architectural judgment
- High-quality long-form prose (thought leadership, detailed analysis)
- Multi-step logic where intermediate reasoning quality matters

**In practice, this means:**
- Research agents: **sonnet**. They search, gather, and summarize. Speed matters more than prose quality.
- Email drafters: **sonnet**. The voice rules in the agent prompt handle tone. Sonnet follows them fine.
- Content reviewers: **sonnet**. Brand compliance is rule-following, not creative reasoning.
- Bug investigators: **sonnet**. Tracing execution paths is systematic, not creative.
- Meeting prep: **sonnet**. Gathering attendee info and past interactions is retrieval-heavy.
- Deep research: **opus** (via the `model` parameter when dispatching). When synthesis quality matters more than speed.
- Content writing: **opus** (when dispatching content-writer). Long-form prose benefits from stronger reasoning.
- Architecture decisions: **opus**. Complex trade-off analysis.

The savings are significant. A sonnet subagent that runs 5 searches and produces a 300-word summary costs a fraction of the same work on opus. Over dozens of subagent dispatches per day, this adds up.

### Agent Anatomy

Every custom agent follows the same pattern:

```yaml
---
name: agent-name
description: One-line description (used for auto-matching)
model: sonnet
tools: Read, Grep, Glob, WebSearch, WebFetch, mcp__specific_tool
---

Role and context paragraph.

## Process
1. Step one
2. Step two

## Output Format
Structured output template.

## Rules
- Constraint one
- Constraint two
```

Key design choices:
- **Tool restrictions**: Each agent only gets the tools it needs. The researcher gets search MCPs. The email drafter gets only file-reading tools (no sending).
- **Output format**: Enforced via the prompt. Researchers return structured findings. Reviewers return pass/fail with issues.
- **Rules section**: Guardrails specific to the task. "Prefer parallel-search" for the researcher. "Do NOT edit files" for the bug investigator.
- **MMA context**: Agents that produce content include MMA naming rules and banned words directly in their prompts.

### Shared Subagents (`~/.claude/agents/`)

12 reusable agents defined at user level:

| Agent | Purpose |
|-------|---------|
| researcher | Multi-source web research with structured findings |
| deep-research | Extended research requiring 3+ sources and synthesis |
| content-writer | Research + long-form content in one context |
| email-drafter | Emails in my natural voice |
| slack-drafter | Casual Slack messages |
| meeting-prep | Attendee research, past interactions, talking points |
| content-reviewer | Review against MMA brand guidelines |
| test-writer | Follows existing test patterns in the project |
| bug-investigator | Traces execution paths, reads logs, identifies root causes |
| doc-writer | Generates/updates documentation from code |
| pr-preparer | PR title, description, and test plan from branch diff |
| migration-planner | Plans migrations with sequenced steps and rollback options |

### Routing Rules

- **sonnet** by default for subagents (fast, cheap, good enough for most tasks)
- **opus** only when the task requires deep reasoning, complex architecture, or high-quality prose
- All coordination stays with MARVIN (subagents never spawn their own subagents)
- Launch multiple subagents simultaneously when tasks are independent

---

## Plugins

17 plugins enabled, providing structured workflows on top of Claude Code's base capabilities.

### Active Plugins

| Plugin | Purpose |
|--------|---------|
| superpowers | Brainstorming, planning, TDD, code review, debugging, verification workflows |
| feature-dev (x2) | Guided feature development with codebase understanding |
| code-review | PR and code review with confidence-based filtering |
| code-simplifier | Code clarity and refactoring |
| skill-creator | Create, evaluate, and optimize skills |
| plugin-dev | Plugin structure, hooks, MCP integration, agent/skill/command development |
| commit-commands | Git commit, push, PR workflows |
| claude-md-management | Audit and improve CLAUDE.md files |
| frontend-design | Production-grade UI/UX with high design quality |
| n8n-mcp-skills | n8n node configuration, validation, workflow patterns |
| ralph-loop | Recurring prompt loops |
| SkillIssue | Search for skills and plugins across marketplaces |
| security-guidance | Security best practices |
| vercel-plugin | Vercel deployment, AI SDK, Next.js, storage, functions |
| telegram | Telegram bot channel management |
| sentry | Error monitoring, SDK setup, issue triage |

### Profile-Toggled Plugins

- **playwright**: ON only in `coding` profile. Browser testing for web projects.
- **context7**: ON only in `coding` profile. Live library/framework docs. (claude.ai Context7 connector always available regardless.)

### LSP Plugins

TypeScript, Pyright, Kotlin, Java, and Swift language server plugins are enabled for code intelligence across projects.

---

## Hooks and Automation

### SessionStart Hook

The only hook currently configured. Runs `~/.claude/scripts/mcp-profile.sh` on every session start to detect the project type and toggle plugins. Timeout: 10 seconds.

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "~/.claude/scripts/mcp-profile.sh",
        "timeout": 10,
        "statusMessage": "Detecting MCP profile..."
      }]
    }]
  }
}
```

### Behavioral Rules (Always-On via CLAUDE.md and Rules Files)

These aren't hooks in the technical sense, but they're behavioral automation encoded in CLAUDE.md and rules files that Claude follows every session:

- **Parallel dispatch**: Automatically spawn subagents for 2+ independent tasks
- **Clipboard copies**: All drafted content goes to `pbcopy` automatically
- **Folder opens**: Generated images/files trigger `open` on the containing folder
- **Cross-model CLI**: Proactively use Gemini/Codex CLI for workshopping and peer review
- **MCP tool selection**: Follow routing rules (parallel-search first for web, Firecrawl for JS scraping, etc.)

---

## Memory System

Claude Code's auto-memory system persists facts, preferences, and project context across sessions. Memory files live at `~/.claude/projects/-Users-alec-marvin/memory/`.

### Memory Types

| Type | Purpose | Example |
|------|---------|---------|
| **user** | Role, preferences, communication style | "Chief AI Architect, prefers dense analytical style" |
| **feedback** | Corrections and confirmed approaches | "No em dashes in drafted text, use commas/colons instead" |
| **project** | Ongoing work, decisions, context | "AI-AF training pivot: Claude first, Zapier second, Yellow Belt postponed" |
| **reference** | Pointers to external resources | "Pipeline bugs tracked in n8n Cloud, MCP registry in memory file" |

### How It Works

- `MEMORY.md` is an index file loaded every session (kept under 200 lines)
- Each memory is a separate .md file with YAML frontmatter (name, description, type)
- Memories are point-in-time: always verify against current state before acting on them
- Memory excludes: code patterns (read the code), git history (use git log), debugging solutions (the fix is in the code), anything in CLAUDE.md files

### Current Memory Index

~30 memory files covering:
- User preferences (email formatting, presentation fonts, title, tool routing)
- Active projects (content pipeline, training strategy, plugin bugs, title brainstorm)
- Reference sources (MCP registry, Notion KB, headshot paths, CLI access patterns)
- Feedback (no em dashes, clipboard copies, folder opens, MCP scope rules)

---

## Security and Permissions

### Permission Model

```json
{
  "defaultMode": "bypassPermissions",
  "permissions": {
    "allow": ["(long list of pre-approved tool patterns)"],
    "deny": ["Bash(chmod -R 777*)"],
    "ask": [
      "Bash(rm -rf *)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(git clean -f*)"
    ]
  }
}
```

- **bypassPermissions** is used because MARVIN is a trusted personal workspace. This is NOT recommended for untrusted repos.
- Destructive commands (rm -rf, force push, hard reset) still require confirmation via the `ask` list.
- `chmod -R 777` is explicitly denied.

### Safety Rules (Encoded in CLAUDE.md)

1. **Confirm before external actions**: Sending emails, posting Slack messages, modifying Asana tasks, publishing content, calendar changes. State exactly what will happen, wait for approval.
2. **Secrets**: API keys in `.env` only. Never hardcode, echo, print, or commit credentials.
3. **Destructive commands**: Must state what the command does, what data could be lost, and get explicit approval.
4. **Safe alternatives preferred**: `git stash` over `git reset --hard`, trash over `rm -rf`.

---

## Project-Specific Setups

Each project has its own CLAUDE.md with architecture, commands, and conventions tailored to that codebase.

### Reptime Radar (`~/rep-radar/`)

Profile: **coding**. Next.js 15 + Supabase + Python scraping worker. 72 frontend files, 26 routes, 15+ database tables. CLAUDE.md documents the full monorepo structure, dev commands, key patterns (Firecrawl scraping, fuzzy matching, Reddit monitoring), and database schema. Deployed on Vercel with Supabase backend.

### MMA RAG Prototype (`~/mma-rag-prototype/`)

Profile: **coding**. Python 3.12 + Streamlit + LangChain + ChromaDB. Evidence-first RAG chatbot for marketing research. CLAUDE.md enforces zero-hallucination constraint, strict mypy, 80% coverage threshold, and handler protocol patterns. Sentry integration for production error monitoring. Session start checklist includes error log review.

### ArcPush (`~/arcpush/`)

Profile: **coding**. Firebase + Chrome MV3 Extension + React Native Android. Personal Pushbullet replacement with Arc browser space targeting. CLAUDE.md covers the multi-package structure (shared, functions, extension, android) and Firebase config.

### MMA Plugin (`~/mma-plugin/`)

Profile: **mma**. Claude Code plugin with 20 MMA skills and a CLAUDE.md that enforces brand/naming/security rules for all staff. Deployed via Claude Teams admin panel. Currently blocked by a plugin mounting bug (anthropics/claude-code#26254); individual skill ZIP uploads serve as the workaround.

---

## Content Pipeline

A personal LinkedIn newsletter ("AI Marketing Intelligence") with an automated content discovery, triage, and drafting pipeline.

### Architecture: MARVIN + n8n Hybrid

```
[n8n Cloud: 4 workflows, 31 automated sources]
    |
    v
[Notion "Content Intake" staging buffer]
    |
    v
[MARVIN/Claude: /triage -> /draft -> /review -> /publish]
```

- **n8n** handles scheduled content discovery: 12 industry RSS feeds, 9 podcast feeds, 10 Reddit subreddits, 1 webhook for manual capture
- **Claude** handles triage, scoring, drafting, image generation, and review
- **Publishing** is manual (draft-and-paste to LinkedIn, no API)

### Slash Commands

- `/draft`: Topic to full post with research, infographic, and metadata
- `/image`: Generate or regenerate infographic (Gemini image generation)
- `/footer`: Composite branded footer (Python script: Pillow + qrcode, 2x render, dynamic background)
- `/publish`: Copy to clipboard, open output folder
- `/triage`: Score and rank content intake items
- `/queue`: View pipeline status
- `/capture`: Quick-capture a content idea

### n8n Intake Workflows (Phase 3)

Four live workflows on n8n Cloud:

| Workflow | ID | Sources | Schedule |
|----------|----|---------|----------|
| Industry RSS | nWGUe8FrSVR4j5v2 | 12 feeds (AdExchanger, IAB, Digiday, Marketing Dive, etc.) | Every 12 hours |
| Podcast RSS | oipwSYyOYDCFPz8N | 9 feeds (Marketing AI Show, Hard Fork, Practical AI, etc.) | Every 12 hours |
| Reddit RSS | JceYaEssngm56kPQ | 10 subreddits | Every 12 hours |
| Web Capture Webhook | p6MCuDXS69JCbYaZ | Manual POST to /webhook/content-capture | On-demand |

Each workflow: polls sources, merges results, deduplicates by URL, normalizes to staging format. Adding a feed is simple: duplicate an RSS node, change the URL, wire it to the merge node.

### Staging Buffer: Notion Database

The handoff between automated discovery (n8n) and interactive triage (Claude):

- **Database:** "Content Intake" in Notion (ID: 640bfa89154f46fb9ab9ed198562f684)
- **Schema:** Title, URL, Source, Source Type, Status (pending/triaged/drafted), Published, Summary, Collected At, Comment
- **n8n writes** via native Notion node after the normalize step
- **Claude reads** via `notion-fetch` and `notion-search` during `/triage`
- **Blocker:** n8n Cloud needs Notion OAuth credentials configured (pending)

Notion was chosen over Google Sheets (no MCP mounted) and n8n Data Tables (no read API accessible from Claude Code). See `pipeline/config/staging-buffer-research.md` for the full options analysis.

### Visual Content Stack

- **Image generation**: Gemini `generate_image` (won a bake-off against Canva AI, which only generates AI art, not data-rich infographics)
- **Palettes**: MMA Gold (#111111 + #FFA400) and Multi-Accent (#141414 + rotating brand colors per section)
- **Footer**: Python script (Pillow + qrcode) with logo, QR code (Bitly link), 2x render + downscale for crispness, dynamic background color sampling from image edge
- **Output**: `~/marvin/content/images/`
- **Content types**: Listicle, deep-dive, cheat-sheet, stat-card, roundup, comparison (each with different aspect ratios defined in prompts.json)

### Infographic Improvement Notes

Lessons from early iterations:
- Key stats (87%, 75%, 6%) should be displayed as large bold numbers, not buried in body text
- Every section should NOT be the same layout. Mix: stat cards, comparison tables, timeline strips, icon rows, pull quotes
- Prompt templates need to enforce "scannable in 5 seconds" rule: someone gets the main message from just the numbers and bold text
- Long-term goal: build a library of section styles that prompts reference by name

### Content Pillars

1. AI in marketing strategy
2. Responsible AI (governance, regulation)
3. Agentic AI for business
4. Claude Code for marketers (guides, cheat sheets, walkthroughs)
5. AI industry analysis (roundups, stat cards)

### Planned Content Series: "Claude Code for Marketers"

A LinkedIn post series that turns this setup into publishable content. Seven posts planned:

1. **My AI Chief of Staff** -- How MARVIN works (session management, context persistence, state files)
2. **20 AI Skills That Beat Prompting** -- Why structured skills outperform ad-hoc prompts
3. **30+ Tools, One AI Assistant** -- MCP architecture and the integration stack
4. **I Automated My Content Pipeline** -- n8n + Claude hybrid with infographic generation
5. **Claude Code for Non-Engineers** -- Business leader's guide (what it is, what it isn't)
6. **The Parallel Agent Pattern** -- Subagent dispatching for research and bulk operations
7. **My AI Safety Rules** -- Confirm-before-send, destructive command protection, secrets management

Each post uses the `/draft` pipeline with Multi-Accent palette infographics. Target: 1 per week.

### Key Files

```
~/marvin/pipeline/
  scripts/composite_footer.py    # Footer compositing
  config/prompts.json            # Prompt templates (both palettes)
  config/n8n-setup-instructions.md  # n8n workflow import/config guide
  config/staging-buffer-research.md # Options analysis for n8n→Claude handoff
  config/notion-staging-setup.md    # Notion database schema and connection steps
  config/infographic-improvements.md # Visual quality iteration notes
  config/series-claude-code-for-marketers.md # Content series plan
  README.md                      # Pipeline documentation
  posts/                         # Published post archives
  intake/                        # Intake staging
  templates/                     # Post templates
```

---

## Scraping Techniques

### Reddit JSON Endpoints (No API Key Required)

Reddit ended self-service API access in November 2025 (PRAW is dead). But every Reddit page has a public `.json` endpoint that returns structured data with full post content, comments, and metadata. No API key, no OAuth, no rate limit beyond basic politeness.

**How it works:**

Append `.json` to any Reddit URL:

```
# Subreddit listing
https://www.reddit.com/r/marketing/new.json?limit=25

# Individual post with full comment tree
https://www.reddit.com/r/marketing/comments/abc123/post_title.json
```

**Subreddit listing** returns:
- `data.children[]` with post objects containing: id, title, url, author, score, num_comments, created_utc, selftext, permalink

**Post endpoint** returns a 2-element array:
- `[0]`: The post itself (same format as listing)
- `[1]`: Full comment tree with recursive `replies` objects

**Implementation pattern** (from RepRadar's `reddit_monitor.py`):

```python
import httpx, asyncio

async def fetch_subreddit_new(subreddit: str, limit: int = 25):
    url = f"https://www.reddit.com/r/{subreddit}/new.json"
    async with httpx.AsyncClient(
        headers={"User-Agent": "YourApp/1.0"},
        follow_redirects=True,
    ) as client:
        await asyncio.sleep(2.0)  # rate limit: 1 req per 2 sec
        resp = await client.get(url, params={"limit": limit})
        data = resp.json()
    return [child["data"] for child in data["data"]["children"]]

async def fetch_post_comments(post_url: str):
    json_url = post_url.rstrip("/") + ".json"
    async with httpx.AsyncClient(
        headers={"User-Agent": "YourApp/1.0"},
        follow_redirects=True,
    ) as client:
        await asyncio.sleep(2.0)
        resp = await client.get(json_url)
        data = resp.json()
    # data[1] contains the comment tree
    return flatten_comments(data[1]["data"]["children"])
```

**Key details:**
- Rate limit: 1 request per 2 seconds (self-enforced via sleep). Reddit will block faster requests.
- User-Agent header required (descriptive, non-generic).
- Comment trees are recursive: each comment has a `replies` field that contains another listing.
- `follow_redirects=True` is essential (Reddit redirects some URLs).
- Works for any public subreddit. Private subreddits return 403.

**Why this matters for Claude Code:**
- Claude's built-in WebSearch is blocked from reddit.com (Anthropic lawsuit)
- Firecrawl also blocks Reddit
- This technique gets full post content AND comments, which no search tool provides
- Used in the content pipeline's n8n RSS intake (10 subreddits monitored)
- Used in RepRadar's Reddit monitor (replica watch community tracking)

### Cloudflare-Protected Sites

Many sites (especially e-commerce) use Cloudflare anti-bot protection. Standard HTTP clients get blocked. Options discovered through RepRadar:

1. **Firecrawl** (best): Handles JS rendering and anti-bot via stealth proxy. 1 credit per page, 500 free credits.
2. **Playwright stealth**: `playwright-extra` with stealth plugin. Free but requires local Chrome. Good for sites Firecrawl can't handle.
3. **Plain httpx**: Only works for unprotected sites and public JSON endpoints.

### LinkedIn Content Access

LinkedIn blocks conventional scraping. Two MCPs handle this:

1. **linkedin MCP** (`linkedin-scraper-mcp`): Chrome-based, on-demand profile and post lookup. Good for individual profiles.
2. **apify-linkedin MCP**: Scheduled post history scraping with engagement stats (likes, comments, shares). Good for content research and competitive analysis.

Firecrawl blocks LinkedIn. Never attempt to scrape LinkedIn with standard HTTP tools.

---

## Workflow Patterns

Reusable patterns that have emerged from daily use. Documented in Notion ("Workflow Patterns" page) and encoded in agent routing rules.

### Research to Write Pattern

**Use when:** Creating content that requires external context.

1. Dispatch `deep-research` or `content-writer` agent (never separate agents for research and writing)
2. Agent searches multiple sources in parallel (web, SharePoint, email, Slack)
3. Agent synthesizes findings AND produces the output
4. Return to MARVIN for review

**Key insight:** The agent that gathers information must also produce the output. Splitting these creates information loss.

### Meeting Follow-Up Pattern

**Use when:** Processing meeting outcomes into segmented communications.

1. Query Granola for meeting transcript (preferred) or Fireflies (legacy)
2. Extract: decisions, action items, key quotes, attendee contributions
3. Segment recipients (attendees vs. stakeholders vs. broader team)
4. Generate tailored follow-up for each segment using `meeting-followup` skill
5. Confirm before sending

### Parallel Research Pattern

**Use when:** Gathering info from 3+ independent sources.

1. Identify independent queries (SharePoint + web + email + Slack)
2. Dispatch parallel subagents (one per source, all sonnet)
3. Synthesize results in MARVIN's context
4. Present unified findings

### Bulk Operations Pattern

**Use when:** Updating multiple systems (Asana + Slack + Email).

1. Gather all items to process
2. Present batch plan for approval ("I'll update 12 Asana tasks and send 3 Slack messages")
3. Execute via `ops-executor` agent
4. Report results

### Pre-Meeting Prep Pattern

**Use when:** Preparing for upcoming calls.

1. Check Outlook calendar for meeting details and attendees
2. Search email/Slack for recent threads with attendees
3. Query Granola for past meetings with same people
4. Check Asana for shared tasks/projects
5. Compile briefing with talking points

### Content Pipeline Pattern

**Use when:** Producing newsletter or social content.

```
/triage → pick topic → /draft → /review → /image → /footer → /publish
```

Each step is a separate slash command. The pipeline supports both full runs and individual step re-runs (e.g., regenerate just the infographic without re-drafting).

### Cross-Model Workshopping Pattern

**Use when:** Important decisions that benefit from diverse perspectives.

1. Frame the question clearly
2. Run through Claude (native reasoning)
3. Dispatch to Gemini CLI (`gemini -p "same question" @context`)
4. Dispatch to Codex CLI (`codex exec --full-auto "same question"`)
5. Synthesize: where do they agree? Where do they diverge? Why?

All three models are on unlimited subscriptions, so this costs nothing extra. The disagreements are where the value is.

### Staging Buffer Pattern (n8n to Notion to Claude)

**Use when:** Automated intake feeds need human triage.

```
n8n (automated discovery) → Notion database (staging buffer) → Claude (/triage command)
```

The Notion database serves as the handoff point between automated and interactive workflows:
- n8n writes new entries via native Notion node (`databasePage: create`)
- Claude reads via `notion-fetch` and `notion-search`
- Status field tracks pipeline state: pending → triaged → drafted → published
- Notion was chosen over Google Sheets (no MCP) and n8n Data Tables (no read API from Claude)

Schema: Title, URL, Source, Source Type, Status, Published date, Summary, Collected At, Comment.

---

## MARVIN: The AI Chief of Staff

MARVIN (Manages Appointments, Reads Various Important Notifications) is the session management layer that wraps everything above into a coherent daily workflow.

### Session Lifecycle

**Start (`/marvin`):**
1. Git pull (sync from other devices)
2. Load state files (current.md, goals.md)
3. Read today's session log (or yesterday's for continuity)
4. Present briefing: priorities, deadlines, progress, open threads

**During:**
- Work naturally across any task
- `/update` to checkpoint mid-session
- Track tasks, take notes, dispatch subagents

**End (`/end`):**
- Summarize session accomplishments and decisions
- Save to `sessions/YYYY-MM-DD.md`
- Update `state/current.md`
- Git push (sync to GitHub for cross-device access)

### State Files

```
~/marvin/state/
  current.md    # Active priorities, open threads, completed items, key file locations
  goals.md      # Work and personal goals with tracking table
```

`current.md` is the canonical source of truth for what's in progress. It's updated at every session end and contains:
- Active priorities (numbered, with status and next actions)
- Open threads (checkbox lists grouped by project)
- Recently completed items (for continuity)
- Key file locations (quick reference)
- Integration status (what's connected, what's broken)

### Session Logs

Daily logs at `~/marvin/sessions/YYYY-MM-DD.md` capture:
- Topics covered
- Decisions made
- Open threads
- Next actions

These serve as a conversation history that persists beyond Claude's context window.

---

## Deployment to Staff

### For claude.ai Web/Mobile Users (All Staff)

The MMA Plugin provides 20 skills automatically. Staff don't need to install anything; the plugin is pushed via Claude Teams admin. Skills cover brand guidelines, writing style, org context, email drafting, social posts, content creation, research briefs, and more.

**Current limitation:** Plugin system has a mounting bug (anthropics/claude-code#26254). Workaround: 19 skills uploaded individually via the Teams admin Skills/Capabilities panel.

### For Claude Code Users (Power Users)

MAVEN template provides:
- All 20 MMA skills
- Session management (start, end, update, report)
- Goal tracking and state persistence
- Safety rules and brand enforcement
- Setup script for first-time install

Installation: clone the repo, run setup.sh, add integrations.

### Training Strategy (April 2026)

Claude is the foundation tool. $6,000/year approved for 20 NA employees. Training structure:
- **Hour 1:** Claude training (live, hands-on)
- **Hour 2:** Zapier overview (no-code automation)
- **Follow-up:** Personal workflow goals discussion
- Sessions recorded for global team access (LATAM, APAC, MEA)

Philosophy: habits over features, doing over lectures, meet people where they are.

---

## Key Lessons Learned

### Architecture

1. **Context is the scarce resource.** Everything in the setup (adaptive profiles, on-demand skills, subagent delegation, CLI offloading) is designed to protect Claude's context window. Large tool results, exploratory research, and file reads are the biggest context consumers.

2. **Rules files over CLAUDE.md bloat.** Split project instructions across small, focused rules files that auto-load. One massive CLAUDE.md becomes hard to maintain and slow to parse.

3. **Skills are better than rules for domain knowledge.** Rules load every session. Skills load on demand. Org context, brand guidelines, and program details belong in skills. Only essential patterns (naming, voice, security) belong in always-on rules.

4. **Two-branch context model is necessary for org deployment.** Staff don't have the same integrations as the admin. Shipping internal paths and Slack channel IDs to users who can't access them wastes their context and confuses Claude.

### Multi-Model

5. **Three models are better than one.** Each model has blind spots. Gemini has Google Search grounding and Reddit data access. GPT brings different reasoning patterns. Claude has the deepest tool integration. Use all three.

6. **CLI offloading compresses context.** When Gemini CLI reads 15 files and returns a 200-word summary, Claude ingests 200 words instead of 15 files. This is not about model quality; it's about context economics.

7. **All three models are on unlimited subscriptions.** There's no marginal cost to querying multiple models. Use them freely for workshopping, peer review, and parallel research.

### Workflow

8. **Never split research from writing.** The agent that gathers information should produce the output. Passing research results to a separate writing agent creates a "telephone game" that degrades quality.

9. **Subagents compress, not expand.** The point of subagents is to distill large exploration into clean signal. Spawn them to protect the main context from noise, not to parallelize for speed.

10. **Session persistence is transformational.** State files, session logs, and auto-memory mean Claude picks up exactly where the last conversation ended. No re-explaining, no lost context. This is the single biggest productivity gain.

### MCP and Integration

11. **parallel-search first, paid services second.** parallel-search is free and handles most web search needs. Firecrawl, Search1API, and Perplexity consume credits; use them only when their specific capabilities (JS rendering, Reddit search, AI synthesis) are needed.

12. **Firecrawl blocks Reddit and LinkedIn.** Use Search1API or Gemini for Reddit. Use linkedin/apify-linkedin MCPs for LinkedIn. Claude's built-in WebSearch is also blocked from reddit.com (Anthropic lawsuit).

13. **Pin MCP versions when latest breaks.** Slack MCP v1.2.3 required a `users:read` scope not on my token. Pinning to v1.1.28 fixed it. Always check what changed before upgrading.

14. **Custom MCPs are simple to build.** The Dynalist, OpenAI, and Grok MCPs are thin wrappers (under 100 lines each) that expose existing APIs as MCP tools. The barrier to creating new integrations is low.

### Subagent Economics

15. **Sonnet for subagents by default.** Every custom agent uses `model: sonnet`. Sonnet follows structured prompts (output formats, brand rules, tool preferences) just as reliably as opus. Reserve opus for the MARVIN orchestrator and tasks requiring genuine deep reasoning.

16. **Subagents are context compression, not just parallelism.** When a researcher agent runs 5 searches and returns a 300-word summary, MARVIN ingests 300 words instead of 5 search results. The same logic applies to CLI offloading: Gemini reads 15 files and returns a summary; Claude never sees the files. Design for context economy, not just speed.

### Scraping and Data Access

17. **Reddit .json endpoints are the best free scraping technique.** Append `.json` to any Reddit URL. Gets full post content, comment trees, metadata. No API key, no OAuth. Rate limit: 1 request per 2 seconds. This is how the content pipeline monitors 10 subreddits and how RepRadar tracks replica watch communities.

18. **Firecrawl for JS-rendered sites, but know its limits.** Firecrawl handles Cloudflare protection and JS rendering, but blocks Reddit and LinkedIn. Use the Reddit .json technique for Reddit, and LinkedIn MCPs for LinkedIn.

19. **Notion as a universal staging buffer.** When automated systems (n8n) need to hand off data to interactive systems (Claude), Notion databases work well. Both sides have native API access. The schema enforces structure, and status fields track pipeline state.

### Security

20. **bypassPermissions is for trusted workspaces only.** MARVIN is personal. For org deployment (MAVEN, MMA Plugin), use standard permission modes. The `.claude/` directory in an untrusted repo could exploit tool permissions.

21. **Confirm-before-send is non-negotiable.** Even in bypassPermissions mode, the CLAUDE.md rules enforce confirmation before sending emails, posting Slack messages, modifying Asana tasks, or publishing content. The cost of an errant message is high.
