---
name: reddit-scrape
description: Scrape Reddit posts and comments via the Apify connector — single post, subreddit, user, or keyword search. Returns structured data (title, body, author, upvotes, comments, images). Use for "scrape Reddit", "get this Reddit post", "Reddit comments on", "what are people saying in r/", "search Reddit", "browse Reddit".
allowed-tools:
  - mcp__claude_ai_Apify__*
  - mcp__apify__*
---

# Reddit Scraping (Apify)

## Setup (skip if Apify is already connected)
Requires the Apify connector (Claude Desktop) with your org's shared Apify token. If a scrape returns an auth or connection error, it isn't set up yet. Tell the user to open the setup guide and follow it: your org's Apify onboarding doc ({{APIFY_SETUP_DOC_URL}}) ({{APIFY_SETUP_DOC_PATH}}).

Tool names: **Claude Desktop** → `Apify:call-actor`, `Apify:get-dataset-items`. **Claude Code** → deferred; load with `ToolSearch("apify call actor dataset")` first, then `mcp__claude_ai_Apify__*` (or `mcp__apify__*`).

## Two-step pattern (every scrape)
1. **`call-actor`** with actor + input JSON. Set `waitSecs: 45` (the max; it returns as soon as the run finishes, ~6–16s, not a fixed delay). Response gives the dataset id (`defaultDatasetId` / `storages.datasets.default.id`), not the rows.
2. **`get-dataset-items`** with that id. **Always** pass `fields=` (rows carry 20–30 columns including HTML bodies).

## Primary actor: `harshmaur/reddit-scraper`
Default. Fast (~6s), 94% success, returns upvotes, images, per-comment upvotes. Cost: $0.02/run + $0.0018/result.

Inputs:
- `startUrls` — array of **OBJECTS**: `[{"url": "..."}]` (bare strings fail). Post, subreddit, user, or search-page URLs.
- `searchTerms` — array of strings; use instead of `startUrls` for keyword search.
- `crawlCommentsPerPost` (bool, default `false`) — scrape comment bodies.
- `maxCommentsPerPost` (int, default 10) — cap; applies only when crawling comments. Each comment is a billed result, so keep it modest.
- `maxPostsCount` (int, default 10, max 900) — `1` for a single post.
- `proxy` — `{"useApifyProxy": true, "apifyProxyGroups": ["RESIDENTIAL"]}` (most reliable for Reddit).
- Search-only: `searchSort` (relevance|hot|top|new|comments), `searchTime` (all|hour|day|week|month|year), `withinCommunity`, `includeNSFW`, `fastMode`.

Post only:
```json
{"startUrls": [{"url": "<POST_URL>"}], "crawlCommentsPerPost": false, "maxPostsCount": 1, "proxy": {"useApifyProxy": true, "apifyProxyGroups": ["RESIDENTIAL"]}}
```
`commentsCount` is still populated; you just don't get bodies.

Post + comments:
```json
{"startUrls": [{"url": "<POST_URL>"}], "crawlCommentsPerPost": true, "maxCommentsPerPost": 50, "maxPostsCount": 1, "proxy": {"useApifyProxy": true, "apifyProxyGroups": ["RESIDENTIAL"]}}
```

Subreddit top this week:
```json
{"startUrls": [{"url": "https://www.reddit.com/r/espresso/"}], "maxPostsCount": 25, "searchSort": "top", "searchTime": "week", "crawlCommentsPerPost": false, "proxy": {"useApifyProxy": true, "apifyProxyGroups": ["RESIDENTIAL"]}}
```

Keyword search: swap `startUrls` for `searchTerms`, e.g. `{"searchTerms": ["espresso machine reviews"], "maxPostsCount": 25, "searchSort": "top", "searchTime": "month", "proxy": {...}}`.

Output rows have `dataType` `"post"` or `"comment"`:
- Post: `dataType, title, body, authorName, upVotes, commentsCount, images, contentUrl, postUrl, createdAt, flair, postType, communityName, id`
- Comment: `dataType, body, authorName, commentUpVotes, commentCreatedAt, parentId, url`

Retrieval:
```
get-dataset-items  datasetId: <id>
  fields: "dataType,title,body,authorName,upVotes,commentsCount,images"                   # post-only
  fields: "dataType,title,body,authorName,upVotes,commentsCount,commentUpVotes,parentId"  # with comments
```

## Fallback: `trudax/reddit-scraper-lite`
Only if harshmaur fails. Slower (~16s), $0.0038/result, 88%, no upvotes/images. Includes comments **by default** — for post-only set `skipComments: true` (not `maxComments: 0`).
```json
{"startUrls": [{"url": "<POST_URL>"}], "skipComments": true, "skipCommunity": true, "maxPostCount": 1, "maxItems": 1, "proxy": {"useApifyProxy": true, "apifyProxyGroups": ["RESIDENTIAL"]}}
```
Output: `dataType, title, body, username, communityName, createdAt, url, parentId`. No `upVotes`.

## Gotchas
1. `startUrls` entries must be objects `{"url": "..."}`. Most common error.
2. Comment defaults differ: harshmaur OFF, trudax ON. Set explicitly; default to post-only.
3. `get-dataset-items` may hit "No approval received"; the run still succeeded, so approve or re-issue.
4. Always project `fields=`.
5. Cost scales per comment: post-only ≈ $0.022; 50 comments ≈ $0.11; 500 ≈ $0.92.

## Defaults
harshmaur, post-only. Scrape comments only when asked. trudax only on harshmaur failure.
