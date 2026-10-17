# Parallel Search Integration

Connect MAVEN to the web with [Parallel Search MCP](https://docs.parallel.ai/integrations/mcp/search-mcp).

## What It Does

- **Web Search** - Search the web and get LLM-friendly results
- **Web Fetch** - Extract relevant content from specific URLs

## Who It's For

Anyone who wants MAVEN to have access to current information from the web.

## Prerequisites

Claude Code must be installed. The hosted service provides free web search powered by Fast mode and page fetching, with no Parallel account or API key needed. Free usage has limits.

## Setup

```bash
./.marvin/integrations/parallel-search/setup.sh
```

The script registers `https://search.parallel.ai/mcp` with Claude Code's HTTP transport. Choose all projects (user scope, the default) or this project only (local scope, kept private to your machine). Existing Parallel settings are kept unless you confirm replacement in the selected scope. Other servers and tool permissions are unchanged.

Restart Claude Code after setup. If you disabled Parallel or denied its tools, enable it through your existing Claude Code controls when you want to use it.

## Try It

After setup, try these commands with MAVEN:

- "Search the web for latest React documentation"
- "What's new in Python 3.12?"
- "Find recent news about AI developments"
- "Look up the current price of Bitcoin"

## Danger Zone

This integration is **read-only** and cannot modify external data.

| Action | Risk Level | Who's Affected |
|--------|------------|----------------|
| Web search | Low | No external impact |
| Fetch URL content | Low | No external impact |

Search queries and requested URLs are sent to Parallel. Claude Code's tool permission controls still apply.

## Troubleshooting

**Search returns no results**
Try rephrasing your query or being more specific.

**Timeout errors**
The service may be temporarily busy. Wait a moment and try again.

**Authentication errors with an older installation**
Run setup again and confirm replacement to migrate from `search-mcp.parallel.ai` to the anonymous endpoint at `search.parallel.ai`. Keep your existing settings if you intentionally use a custom or authenticated server.

**Usage limit reached**
Wait for the service's indicated retry time before trying again.

**Tools available**
`web_search` returns relevant excerpts and source URLs. `web_fetch` extracts content from specific URLs when you need more detail.

---

*Created by Sterling Chin*
