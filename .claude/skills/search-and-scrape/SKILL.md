---
name: search-and-scrape
description: Use BEFORE any web search, lookup, or page fetch/scrape to pick the right tool instead of defaulting to one. Routes SEARCH across parallel-search (general default), Exa (semantic / find-similar / discovery), and Perplexity (synthesized cited answers + deep research); routes FETCH across Jina Reader (default, fast/cheap) and Firecrawl (JS-heavy / anti-bot / structured extract / crawl). Defers to linkedin-scrape and reddit-scrape for those platforms. Triggers on "search", "look up", "find out", "research", "scrape", "fetch this page", "get this article".
---

# Search & Scrape Routing

Pick the tool that fits the job. Do not reflexively use one tool for everything. The two tables below are the decision logic.

## SEARCH — finding information on the web

| Situation | Tool | Why |
|---|---|---|
| **Default** — facts, news, "what is X", finding a URL, most lookups | **parallel-search** (`web_search`/`web_fetch`) | Cheap (effectively unlimited here), fast, LLM-optimized excerpts. Handles ~90% of searches. |
| "Find pages **like** this", discovery by **meaning** not keywords, niche/technical sources, specific entity pages (papers, company/people pages), "find similar / find more like" | **Exa** (`web_search_exa`) | Neural/semantic search. Wins when keyword search returns junk or you want conceptual matches. Free tier is generous; content bundled with results. |
| Need a **synthesized, cited answer** (not a list of links), multi-hop factual question | **Perplexity** `perplexity_ask` | Returns an answer with citations in one shot. |
| **Deep research report** — multi-source, comprehensive, time OK to spend 30s+ | **Perplexity** `perplexity_research` | Heaviest/most expensive; reserve for genuine deep dives. |
| Step-by-step analytical reasoning over web facts | **Perplexity** `perplexity_reason` | |

**Don't:** use `perplexity_search` (raw links) — parallel-search already returns links cheaper. Don't burn `perplexity_research` credits on questions `perplexity_ask` or parallel-search can answer. Don't reach for Exa when a plain keyword search would find it.

**Reddit search note:** built-in WebSearch is blocked from reddit.com. Use parallel-search with `site:reddit.com`, or Gemini.

## FETCH / SCRAPE — pulling content from a specific URL

| Situation | Tool | Why |
|---|---|---|
| **Default** — fetch a normal article/page as clean markdown | **Jina Reader** (`jina_reader`) | Fast, free, clean markdown. First choice for static/simple pages. |
| Page is **JS-heavy / SPA**, behind **anti-bot/Cloudflare**, needs **structured extraction** (schema), **multi-page crawl**, browser actions, or screenshots | **Firecrawl** (`firecrawl_scrape` / `firecrawl_crawl` / `firecrawl_extract`) | Renders JS, defeats anti-bot, extracts structured data, crawls sites. Costs credits — escalate to it only when Jina returns junk or the page needs rendering. |
| Firecrawl Stealth mode | use sparingly | 5 credits/page vs 1 — don't hit protected sites at volume casually. |

**Escalation rule:** try Jina first. If the result is empty/garbled or the page is clearly dynamic, escalate to Firecrawl.

## Platform-specific — DEFER to the dedicated skills

- **LinkedIn** (profiles, posts, people/company search): both Firecrawl and Jina are **blocked**. Use the **`linkedin-scrape`** skill (LinkedIn MCP default, Apify for large bulk). Do not attempt Firecrawl/Jina/WebFetch on linkedin.com.
- **Reddit** (posts, comments, subreddits, keyword search): Firecrawl, Jina, and WebFetch are all **blocked** from reddit.com. Use the **`reddit-scrape`** skill, or append `.json` to a Reddit URL, or Gemini/Search1API.

## Notes
- `webcrawler` MCP is disabled — Firecrawl + Jina cover its use cases.
- Skills don't apply in Claude Desktop/mobile; this routing is for Claude Code.
