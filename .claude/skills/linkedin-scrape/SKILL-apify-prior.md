> **PRIOR VERSION (Apify-based) — archived, not loaded as a skill.**
> Superseded by the LinkedIn MCP approach in `SKILL.md` (free, uses your own LinkedIn session). Kept as a fallback: Apify runs on a shared **paid** account with **no personal-LinkedIn-account risk**, so prefer it for staff/shared rollout, higher volume, or verified-email lookups. The MCP version drives your own logged-in account and carries ToS/account-restriction risk.

---
name: linkedin-scrape
description: Scrape LinkedIn via the Apify connector — profile details, profile posts, people search, and company-employee lookup. No login cookies. Use for "look up LinkedIn profile", "scrape LinkedIn posts", "find the [title] at [company]", "search LinkedIn for [criteria]", "get someone's LinkedIn email".
allowed-tools:
  - mcp__claude_ai_Apify__*
  - mcp__apify__*
---

# LinkedIn Scraping (Apify)

Four use cases: **A** profile details, **B** profile posts, **C** people search, **D** company-employee lookup.

## Setup (skip if Apify is already connected)
Requires the Apify connector (Claude Desktop) with your org's shared Apify token. If a scrape returns an auth or connection error, it isn't set up yet. Tell the user to open the setup guide and follow it: your org's Apify onboarding doc ({{APIFY_SETUP_DOC_URL}}) ({{APIFY_SETUP_DOC_PATH}}).

Tool names: **Claude Desktop** → `Apify:call-actor`, `Apify:get-dataset-items`. **Claude Code** → deferred; load with `ToolSearch("apify call actor dataset")` first.

## Two-step pattern
1. **`call-actor`** with actor + input, `waitSecs: 45` (the max; returns as soon as the run finishes). Gives a `datasetId`, not the rows.
2. **`get-dataset-items`** with that id, **always** projecting `fields=` (actors return 80–230 columns).

---

## A — Profile details
| Need | Actor | Price | Returns |
|---|---|---|---|
| Profile, no contact info (default) | `harvestapi/linkedin-profile-scraper` (no-email) | $0.004/profile | full profile, no email/phone |
| Email + phone | `dev_fusion/Linkedin-Profile-Scraper` | $0.01/profile | full profile + email + phone |
| Verified email, bulk | `harvestapi/linkedin-profile-scraper` (email mode) | $0.01/profile | profile + email flags; empty when unverifiable; no phone |

For "get this person's email/phone," use dev_fusion (returns both). harvestapi email mode is for bulk verified-deliverable lists and has lower hit rates (returns empty when it can't verify).

### harvestapi/linkedin-profile-scraper
- `profileScraperMode` (EXACT string incl. price suffix): `"Profile details no email ($4 per 1k)"` or `"Profile details + email search ($10 per 1k)"`.
- Provide `publicIdentifiers` (slugs); **default to this**, since `urls` returned empty in testing. Slug = last segment of `linkedin.com/in/<slug>`.
```json
{ "profileScraperMode": "Profile details no email ($4 per 1k)", "publicIdentifiers": ["<slug>"] }
```
Email mode adds an `emails` array: `email, status, deliverable, qualityScore, free, catchAllDomain`.
Projection: `fields: "firstName,lastName,headline,currentPosition.companyName,currentPosition.position,location.linkedinText,about,followerCount,connectionsCount,publicIdentifier,skills.name"`

### dev_fusion/Linkedin-Profile-Scraper
`profileUrls` (full URLs or slugs); returns email + phone by default.
```json
{ "profileUrls": ["https://www.linkedin.com/in/<slug>/"] }
```
Projection: `fields: "fullName,headline,jobTitle,companyName,addressWithCountry,about,email,mobileNumber,publicIdentifier,totalExperienceYears,experiencesCount"`

---

## B — Profile posts

### harvestapi/linkedin-profile-posts (default) — $0.002/post
Returns text, media URLs, and reaction/comment/share **counts** free with each post.
**Cost trap:** `scrapeReactions`/`scrapeComments` are billed **per record** ($0.002 each, one charge per individual reaction/comment). Counts come free, so default both **OFF**.
```json
{ "targetUrls": ["https://www.linkedin.com/in/<slug>/"], "maxPosts": 20, "scrapeReactions": false, "scrapeComments": false }
```
Output: `content`; `postImages.url`, `header.image.url` (media); `engagement.likes/comments/shares`, `engagement.reactions.type/.count`; `postedAt.date`; `author.name`; `linkedinUrl`; `repostedBy.*`. Rows have `type` `"post"`/`"reaction"`.
Projection: `fields: "type,content,postImages,header,engagement,postedAt,author,linkedinUrl,repostedBy"`
Comment text costs extra (`scrapeComments: true`, `maxComments: <n>`), or use `harvestapi/linkedin-post-comments`.

### apimaestro/linkedin-profile-posts (alt) — $0.005/post
Flat price, no add-ons, faster (~5s). Comment count only, no comment text.
```json
{ "username": "<slug>", "total_posts": 20 }
```
Output: `media.url`, `media.images.url`; flat `stats.total_reactions/like/love/insight/support/celebrate/funny/comments/reposts`; `posted_at.date`.

**Avoid `supreme_coder/linkedin-post`:** failed 3/3 in testing (leaked session cookies; its "no cookies" claim is false).

---

## C — People search
### harvestapi/linkedin-profile-search
**Needs a one-time permission approval.** The call returns an approval URL; surface it and stop, then retry after approval.
Pricing: $0.10/search page (≤25 short profiles) + $0.004/full or $0.01/full+email.
Input: `searchQuery`, `currentJobTitles[]`, `currentCompanies[]` (URLs), `locations[]`, `seniorityLevelIds[]`, `functionIds[]`, `industryIds[]`, `schools[]`, `recentlyChangedJobs`, `recentlyPostedOnLinkedIn`, `maxItems`, `profileScraperMode` (`"Short"`/`"Full"`/`"Full + email search"`).
- Seniority: 110 Entry · 120 Senior · 130 Strategic · 200 Entry Mgr · 210 Exp Mgr · 220 Director · 300 VP · 310 CXO · 320 Owner/Partner
- Function: 8 Eng · 10 Finance · 12 HR · 13 IT · 14 Legal · 15 Marketing · 18 Operations · 19 Product · 25 Sales
```json
{ "searchQuery": "Chief Marketing Officer", "locations": ["United States"], "seniorityLevelIds": ["310"], "functionIds": ["15"], "maxItems": 10, "profileScraperMode": "Short" }
```

---

## D — Company-employee lookup ("CMO at Best Buy")
### harvestapi/linkedin-company-employees
Company-anchored; same filters as C. **Also needs one-time permission approval.** Pricing: $0.02 start + $0.003 short / $0.008 full / $0.012 full+email per profile.
```json
{ "companies": ["https://www.linkedin.com/company/best-buy"], "jobTitles": ["Chief Marketing Officer"], "seniorityLevelIds": ["310"], "profileScraperMode": "Short ($4 per 1k)", "maxItems": 5 }
```
Use D when company-anchored; C when criteria span companies.

---

## No single profile+posts actor
None returns profile + posts together. Chain A + B (two runs).

## Gotchas
1. `publicIdentifiers` > `urls` for harvestapi profiles (`urls` returned empty). Slug = last URL segment.
2. Exact `profileScraperMode` strings incl. price suffix, or validation fails.
3. Permission gates (C, D): surface the approval URL and stop; retry after approval.
4. Reaction/comment cost trap (B): billed per record. Default OFF; counts are free.
5. Always project `fields=`.
6. `get-dataset-items` may hit an approval gate; the run still succeeded, so approve or re-issue.

## Defaults
Profiles → harvestapi `publicIdentifiers` no-email; dev_fusion for email/phone. Posts → harvestapi, reactions/comments OFF. C/D only after permission approval.
