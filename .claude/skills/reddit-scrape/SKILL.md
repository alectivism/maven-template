---
name: reddit-scrape
description: Scrape Reddit posts and comments via the Apify connector — single post, subreddit, user, or keyword search. Returns structured data (title, body, author, upvotes, comments, images). Use for "scrape Reddit", "get this Reddit post", "Reddit comments on", "what are people saying in r/", "search Reddit for".
allowed-tools:
  - mcp__claude_ai_Apify__*
  - mcp__apify__*
---

# Reddit Scraping (Apify)

Pulls Reddit content (a single post, a subreddit's posts, a user's activity, or keyword search results) plus optional comments, returning structured rows: title, body, author, upvote score, comment count, images, timestamps.

## Before you start

**First-time setup (skip if Apify is already connected).** Requires the Apify connector with your org's shared Apify token. If a scrape returns an auth or connection error, the connector isn't configured yet. Tell the user to open your org's Apify setup guide and follow it: {{APIFY_SETUP_DOC_URL}} ({{APIFY_SETUP_DOC_PATH}}). One-time manual paste; Claude can't set the token.

**Tool names vary by environment:**
- **Claude Desktop / claude.ai:** tools are `Apify:call-actor` and `Apify:get-dataset-items`.
- **Claude Code:** tools are deferred. Load them first — `ToolSearch("apify call actor dataset")` — then call `mcp__claude_ai_Apify__call-actor` / `mcp__claude_ai_Apify__get-dataset-items` (or the `mcp__apify__` variants).

**Cheaper free alternative for a single public post:** appending `.json` to any Reddit URL returns the full post + comments with no API key and no cost (e.g. `WebFetch` the `.json` URL). Prefer that for one known public thread. Use Apify when you need keyword search, subreddit sweeps, user activity, anti-bot resilience, or clean structured rows across many posts.

## The two-step pattern (every scrape)

1. **`call-actor`** with the actor name + input JSON, and `waitSecs: 45` so the run finishes synchronously (Reddit runs take 6–16s). The response returns run metadata including the dataset id (`defaultDatasetId`, a.k.a. `storages.datasets.default.id`). It does **not** contain the row data.
2. **`get-dataset-items`** with that dataset id to retrieve the rows. **Always** pass `fields=` to project columns — Reddit rows carry 20–30 columns including HTML bodies, and unprojected reads waste tokens.

## Primary actor: `harshmaur/reddit-scraper`

Default to this. Fast (~6s), cheap, 94% success, returns upvote scores, images, and per-comment upvotes. Cost: $0.02 per run start + $0.0018 per result.

Input fields that matter:
- `startUrls` — array of **OBJECTS**: `[{"url": "https://www.reddit.com/r/<sub>/comments/<id>/"}]`. Bare strings fail validation. Supports post, subreddit, user-profile, and search-page URLs.
- `searchTerms` — array of strings; use instead of `startUrls` for keyword search.
- `crawlCommentsPerPost` (bool, default `false`) — whether comment bodies are scraped.
- `maxCommentsPerPost` (int, default 10) — comment cap per post; only applies when `crawlCommentsPerPost` is true. Raise to ~500 for a busy thread.
- `maxPostsCount` (int, default 10, max 900) — set to `1` for a single known post.
- `proxy` — pass `{"useApifyProxy": true, "apifyProxyGroups": ["RESIDENTIAL"]}`. Residential is most reliable for Reddit.
- Optional (search/keyword scrapes): `searchSort` (relevance|hot|top|new|comments), `searchTime` (all|hour|day|week|month|year), `withinCommunity` (e.g. `"r/espresso"`), `includeNSFW` (bool), `fastMode` (bool).

### Recipe — post content only (no comments)
```json
{
  "startUrls": [{"url": "<POST_URL>"}],
  "crawlCommentsPerPost": false,
  "maxPostsCount": 1,
  "proxy": {"useApifyProxy": true, "apifyProxyGroups": ["RESIDENTIAL"]}
}
```
Returns 1 item. `commentsCount` is still populated (the number); you just don't get comment bodies.

### Recipe — post + comments
```json
{
  "startUrls": [{"url": "<POST_URL>"}],
  "crawlCommentsPerPost": true,
  "maxCommentsPerPost": 50,
  "maxPostsCount": 1,
  "proxy": {"useApifyProxy": true, "apifyProxyGroups": ["RESIDENTIAL"]}
}
```
Raise `maxCommentsPerPost` to 500 for nearly all comments on a busy thread. The cap governs — neither actor returns truly unlimited comments.

### Recipe — subreddit top posts this week
```json
{
  "startUrls": [{"url": "https://www.reddit.com/r/espresso/"}],
  "maxPostsCount": 25,
  "searchSort": "top",
  "searchTime": "week",
  "crawlCommentsPerPost": false,
  "proxy": {"useApifyProxy": true, "apifyProxyGroups": ["RESIDENTIAL"]}
}
```

### Recipe — keyword search
Replace `startUrls` with `searchTerms`: `{"searchTerms": ["espresso machine reviews"], "maxPostsCount": 25, "searchSort": "top", "searchTime": "month", "proxy": {...}}`.

### Output fields
Each row has `dataType` = `"post"` or `"comment"`.
- **Post rows:** `dataType, title, body, authorName, upVotes, commentsCount, images, contentUrl, postUrl, createdAt, flair, postType, communityName, id`
- **Comment rows:** `dataType, body, authorName, commentUpVotes, commentCreatedAt, parentId, url`

### Retrieval call
```
get-dataset-items
  datasetId: <from call-actor response>
  fields: "dataType,title,body,authorName,upVotes,commentsCount,images"                      # post-only
  fields: "dataType,title,body,authorName,upVotes,commentsCount,commentUpVotes,parentId"     # with comments
  limit: <maxPostsCount + expected comments>
```

## Fallback actor: `trudax/reddit-scraper-lite`

Use only if `harshmaur` fails. More mature (25k users) but slower (~16s), pricier ($0.0038/result), 88% success, and it does **not** return upvote scores or images.

Key difference: trudax includes comments **by default** (`skipComments: false`, `maxComments: 10`). For post-only you must set `skipComments: true` — do not rely on `maxComments: 0`.

```json
{
  "startUrls": [{"url": "<POST_URL>"}],
  "skipComments": true,
  "skipCommunity": true,
  "maxPostCount": 1,
  "maxItems": 1,
  "proxy": {"useApifyProxy": true, "apifyProxyGroups": ["RESIDENTIAL"]}
}
```
Thinner output: `dataType, title, body, username, communityName, createdAt, url, parentId`. No `upVotes`.

## Gotchas
1. **`startUrls` entries must be objects** `{"url": "..."}`. Bare strings fail validation — the most common error.
2. **Comment defaults differ by actor:** harshmaur OFF, trudax ON. Set the relevant flag explicitly every time; default behavior is post-only.
3. **Approval gate:** `get-dataset-items` can hit "No approval received" in some session configs. The run still succeeded — approve the dataset read or re-issue it.
4. **Always project `fields=`.** Unprojected reads dump HTML bodies and waste tokens.
5. **Cost framing:** one post, no comments ≈ $0.02 + $0.0018 ≈ $0.022. A post with 50 comments ≈ $0.02 + 51 × $0.0018 ≈ $0.11.

## Defaults
Default to `harshmaur`, post-only. Scrape comments only when the user asks. Fall back to `trudax` only on harshmaur failure.
