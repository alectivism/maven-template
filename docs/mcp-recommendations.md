# Recommended MCP Servers

MCP (Model Context Protocol) servers extend Claude Code with new capabilities — search, scraping, dashboards, integrations. This template ships with a core set in `.marvin/integrations/`. Below are *additional* MCPs worth considering depending on your work.

## Quick install

Most are one command. Example:

```bash
claude mcp add --scope user <name> -- npx -y <package>
```

Then `claude mcp list` to confirm.

For OAuth-based MCPs (Notion, Slack, etc.), use `claude mcp auth <name>` to walk through the flow.

---

## Recommended (by category)

### Research & search

**Parallel Search** — Multi-source web search optimized for AI. Fast, citations included, free tier.
- `claude mcp add --scope user parallel-search -- npx -y @parallel-web/parallel-mcp`

**Perplexity** — Web-grounded answers with citations. Great for current-events questions.
- Three modes: `perplexity_ask` (quick), `perplexity_search` (URLs), `perplexity_research` (deep, 30s+).

**Exa** — Semantic web search. Better than Google for finding articles by *meaning* rather than keyword.

**Tavily** — Free, good for tool-calling research workflows.

### Web scraping & extraction

**Firecrawl** — Scrape, crawl, and extract from any website. Handles JS-rendered pages.
- `claude mcp add --scope user firecrawl -- npx -y firecrawl-mcp`

**Apify** — Marketplace of pre-built "actors" for scraping. Good for LinkedIn profiles, Google Maps, Reddit, etc.
- `claude mcp add --scope user apify -- npx -y apify-mcp`

**Jina Reader** — Convert any URL to clean markdown. Fast, free.

### Meetings & calendars

**Granola** — Pulls your meeting transcripts. Best-in-class summarization. Replaces manual note-taking.
- Connect via Settings → Integrations in Claude.ai, or via local MCP.

**Fireflies** — Alternative to Granola. Good if your org has it.

**Google Calendar** / **Microsoft 365** — Read your schedule, find meeting availability, propose times.

### Documentation lookup

**Context7** — Fetches *current* documentation for any library/SDK/framework on demand. Avoids stale training-data answers.
- `claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp`

### Productivity

**Linear** — Read/write issues, projects, cycles. Strong if your team uses it.

**Notion** — Search and read pages, query databases, create pages.

**Asana** — Tasks, projects, comments. Native MCP from Asana.

**Slack** — Read channels, search history, send messages. Requires OAuth.

**Todoist** — Personal task management.

### Browser automation

**Playwright (Microsoft)** — Spin up a real browser, click around, take screenshots. Useful for QA, web app testing, and visual verification of your own deploys.

### CRM & sales

**Apollo.io** — Prospect research, contact enrichment, sequences.

**HubSpot** — CRM with contact + deal management.

### Image & media

**Gemini** (via Google AI Studio) — Image generation, multi-modal analysis. Useful for og-images, social cards, illustrations.

**ElevenLabs** — Text-to-speech, voice cloning.

---

## How to choose

Don't install everything. Start with:

1. **One search MCP** (Parallel Search or Perplexity)
2. **One documentation MCP** (Context7) — only if you write code
3. **One scraping MCP** (Firecrawl) — only if you research a lot
4. **Your real productivity tools** (whichever of Linear/Notion/Asana you actually use)

Then add more as the gap becomes obvious.

---

## When you outgrow the recommendations

- Browse https://github.com/modelcontextprotocol/servers for the canonical list
- Build your own — MCP servers are short Node/Python scripts. See `.marvin/integrations/_template/` for a starter
- Ask MAVEN to find an MCP for a specific need: *"Help me find an MCP server for X"*

---

## Security notes

- Never commit MCP API keys to git. Use `.env` (gitignored) for secrets.
- For OAuth MCPs, the auth lives in your Claude Code keychain — also not committed.
- Review the scope of what an MCP can read/write before installing one from an unknown publisher.
