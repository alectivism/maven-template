---
name: linkedin-scrape
description: Scrape LinkedIn — a person's profile and posts, people and company search, company posts and employees. Free local MCP for most tasks; Apify connector for large bulk, verified emails, or shared/no-account-risk use. Use for "look up LinkedIn profile", "scrape [person]'s posts", "find people at [company]", "search LinkedIn for [criteria]".
allowed-tools:
  - mcp__linkedin__*
  - mcp__claude_ai_Apify__*
  - mcp__apify__*
---

# LinkedIn

Two backends. **Default to the free local MCP for most tasks.** Switch to **Apify** for large bulk, verified contact info, reliable company-anchored queries, or anything run across staff.

| Need | Backend |
|---|---|
| A person's profile or posts; your feed; messaging | MCP |
| People / company search | MCP |
| Small batches (≈ up to a couple dozen), paced | MCP |
| Large bulk (many dozens+) or recurring scraping | Apify |
| Verified email + phone | Apify |
| Company by exact URL, employee lists, department headcount | Apify |
| Shared across staff with no personal-account risk | Apify |

**Account risk & pacing (MCP):** it drives *your own* logged-in LinkedIn account through an automation browser, against LinkedIn's User Agreement. It handles most tasks, including small batches — but **meter them**: keep counts modest (roughly a couple dozen at a time), space calls out instead of firing rapidly, and request only the sections you need. Rapid-fire scraping triggers per-tool timeouts and LinkedIn 403/challenge pages; sustained heavy use risks an account restriction. For large bulk (many dozens or hundreds) or recurring jobs, use Apify (shared paid account, no personal-account exposure).

---

# Option A — `linkedin` MCP (default, free)

[stickerdaniel/linkedin-mcp-server](https://github.com/stickerdaniel/linkedin-mcp-server) — free, local, uses your own LinkedIn session. No API key, no per-call cost.

## Setup (skip if the `linkedin` MCP is connected)
If LinkedIn tools aren't available, tell the user to install it:
- **Claude Desktop (easiest):** download the latest `.mcpb` from <https://github.com/stickerdaniel/linkedin-mcp-server/releases> and click it to install.
- **Any client (uvx):** add an MCP server `linkedin` → `command: uvx`, `args: ["mcp-server-linkedin@latest"]`, `env: {"UV_HTTP_TIMEOUT": "300"}`.

First tool call opens a browser to log in (2FA/captcha OK, ~5 min); session saves to `~/.linkedin-mcp/`. If an early call returns "setup in progress", wait and retry. Re-login when it expires: `uvx mcp-server-linkedin@latest --login`.

## Tools & recipes
- `get_person_profile(linkedin_username, sections, max_scrolls)` — `sections` = comma list of: experience, education, interests, honors, languages, certifications, skills, projects, contact_info, **posts**. Main page always included.
  - **A person's posts:** `get_person_profile("<slug>", sections="posts")`; raise `max_scrolls` for more.
- `get_my_profile(sections)` — your own profile (same sections).
- `get_company_profile(company_name, sections)` — `sections`: posts, jobs. **Slug-sensitive (see gotcha).**
- `get_company_posts`, `get_company_employees(company_name, keyword?)`.
- `search_people(keywords, location?, network?, current_company?)`, `search_companies`, `search_jobs`, `get_job_details`, `get_feed`.
- `get_inbox` / `get_conversation` / `search_conversations`; `connect_with_person` / `send_message` (**write actions — confirm first**); `close_session`.

Slug = last URL segment (`linkedin.com/in/williamhgates` → `williamhgates`). Output is semi-structured text plus a clean `references` array of linked profile/company/post URLs.

## MCP gotchas
- **Company-by-name is ambiguous** — a plain slug can hit the wrong company (e.g. `anthropic` returned a VC fund, not the AI lab). Verify with `search_companies` or use the exact vanity slug.
- **Search filters are fuzzy** — LinkedIn often ignores location; `current_company` needs the numeric URN (from `get_company_profile`), not a name.
- **Browser-based and serialized** (one call at a time). Meter small batches — pace calls, modest counts, minimal sections — to avoid timeouts and 403s. Send large bulk to Apify.

---

# Option B — Apify (large bulk, emails, shared, no account risk)

Apify connector with your org's shared Apify token. **Setup:** open your org's Apify onboarding doc ({{APIFY_SETUP_DOC_URL}}) ({{APIFY_SETUP_DOC_PATH}}). Pattern: `call-actor` (`waitSecs: 45`) → `get-dataset-items` (always project `fields=`). Full recipes: `SKILL-apify-prior.md`.

Pick the actor by need:
- **Profile, no contact info:** `harvestapi/linkedin-profile-scraper` → `{"profileScraperMode":"Profile details no email ($4 per 1k)","publicIdentifiers":["<slug>"]}` (use `publicIdentifiers`, not `urls`).
- **Email + phone:** `dev_fusion/Linkedin-Profile-Scraper` → `{"profileUrls":["https://www.linkedin.com/in/<slug>/"]}`.
- **A person's posts:** `harvestapi/linkedin-profile-posts` → `{"targetUrls":["…/in/<slug>/"],"maxPosts":20,"scrapeReactions":false,"scrapeComments":false}` (reaction/comment scraping bills per record — leave OFF).
- **People search:** `harvestapi/linkedin-profile-search` (one-time permission approval — surface the URL, retry). Filters incl. `seniorityLevelIds` (310 CXO, 220 Director…), `functionIds` (15 Marketing, 8 Engineering…).
- **Company employees:** `harvestapi/linkedin-company-employees` (same filters; permission approval). Pass the full company URL.
- **Department headcount:** `scrapemint/linkedin-company-employees-scraper` (free) → `{"companyUrls":["…/company/<slug>/"],"includeInsights":true}` returns `totalEmployees` + `insights.jobFunctions` distribution.

## Apify gotchas
- Exact `profileScraperMode` strings (incl. the price suffix) or validation fails.
- People-search and company-employees need a one-time permission approval.
- Always project `fields=`; profiles return 130–230 columns.

---

Tool-name prefix varies by client: `mcp__linkedin__*` / `mcp__apify__*` (Claude Code) vs `linkedin:*` / `Apify:*` (Claude Desktop).
