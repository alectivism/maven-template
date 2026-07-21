---
name: linkedin-scrape
description: Find LinkedIn profiles, posts, companies, and people. Use the LinkedIn MCP by default; use Apify for high-volume or contact-enrichment work.
allowed-tools:
  - mcp__linkedin__*
  - mcp__claude_ai_Apify__*
  - mcp__apify__*
---

# LinkedIn

Use the LinkedIn MCP for normal, small-batch research. Use Apify for large or recurring batches, verified email/phone enrichment, exact company-URL employee searches, or work that must avoid a personal LinkedIn session.

Keep MCP calls serialized, request only needed sections, and pace small batches. Confirm before messaging or connection requests.

- MCP connected: read `references/linkedin-mcp.md`.
- MCP unavailable, or Apify is the better fit: read `references/apify-fallback.md`.
