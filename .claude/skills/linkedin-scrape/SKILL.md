---
name: linkedin-scrape
description: Scrape LinkedIn via the Apify connector — profile details, profile posts, people search, and company-employee lookup. No login cookies. Use for "look up LinkedIn profile", "scrape LinkedIn posts", "find the <title> at <company>", "search LinkedIn for <criteria>", "get someone's LinkedIn email".
allowed-tools:
  - mcp__claude_ai_Apify__*
  - mcp__apify__*
---

# LinkedIn Scraping (Apify)

Four use cases: **A** profile details, **B** profile posts, **C** people search, **D** company-employee lookup. Route by what the user wants.

## First-time setup (skip if Apify is already connected)
Requires the Apify connector with your org's shared Apify token. If a scrape returns an auth or connection error, the connector isn't configured yet. Tell the user to open your org's Apify setup guide and follow it: {{APIFY_SETUP_DOC_URL}} ({{APIFY_SETUP_DOC_PATH}}). One-time manual paste; Claude can't set the token.

## Two-step pattern (every scrape)
1. **`call-actor`** with actor name + input, `waitSecs: 45` → returns a `datasetId` (`defaultDatasetId` / `storages.datasets.default.id`), not the rows.
2. **`get-dataset-items`** with that id, **always** projecting `fields=` — LinkedIn actors return 80–230 columns.

Tools are deferred in Claude Code: load with `ToolSearch("apify call actor dataset")` first. On Desktop/web they're `Apify:call-actor` / `Apify:get-dataset-items`.

**PII / compliance:** profile and email scrapers capture personal data. For third-party, non-public-interest use, confirm a lawful basis (GDPR/CCPA) and prefer no-email modes unless contact data is actually required.

---

## A — Profile details

Pick the actor by whether contact info is needed:

| Need | Actor | Price | Returns |
|---|---|---|---|
| Profile data, no contact info (default) | `harvestapi/linkedin-profile-scraper` (no-email mode) | $0.004/profile | full profile, no email/phone |
| Email + phone | `dev_fusion/Linkedin-Profile-Scraper` | $0.01/profile | full profile + email + phone, no verification metadata |
| Verified email at scale (bulk outreach) | `harvestapi/linkedin-profile-scraper` (email mode) | $0.01/profile | profile + verified email flags; empty when unverifiable; no phone |

Tested: on a real profile, dev_fusion returned both email and phone at $0.01; harvestapi's $0.01 email mode returned an empty `emails` array and has no phone field. **Default to dev_fusion when the goal is "get this person's email/phone."** Use harvestapi email mode only for bulk lead lists where you want verified-deliverable addresses and accept lower hit rates.

### harvestapi/linkedin-profile-scraper
- `profileScraperMode` (enum — EXACT string, including price suffix):
  - `"Profile details no email ($4 per 1k)"`
  - `"Profile details + email search ($10 per 1k)"`
- One of: `publicIdentifiers` (slugs), `urls`, `queries`, `profileIds`. **Use `publicIdentifiers` by default** — `urls` returned empty in testing. Slug = last segment of `linkedin.com/in/<slug>`.

```json
{ "profileScraperMode": "Profile details no email ($4 per 1k)", "publicIdentifiers": ["<slug>"] }
```
Email mode: swap `profileScraperMode` to `"Profile details + email search ($10 per 1k)"`. Email data lands in an `emails` array: `emails.email, emails.status, emails.deliverable, emails.qualityScore, emails.free, emails.catchAllDomain`.

Projection: `fields: "firstName,lastName,headline,currentPosition.companyName,currentPosition.position,location.linkedinText,about,followerCount,connectionsCount,publicIdentifier,skills.name"`

### dev_fusion/Linkedin-Profile-Scraper
- `profileUrls` (array of full URLs): accepts full URLs or slugs.
```json
{ "profileUrls": ["https://www.linkedin.com/in/<slug>/"] }
```
Returns email + phone by default. Projection: `fields: "fullName,headline,jobTitle,companyName,addressWithCountry,about,email,mobileNumber,publicIdentifier,totalExperienceYears,experiencesCount"`

**Privacy:** dev_fusion pulls email + mobile automatically, no opt-in. Surface this and confirm lawful basis before batch-scraping third parties.

---

## B — Profile posts

### harvestapi/linkedin-profile-posts (default) — $0.002/post
Returns post text, media URLs, and reaction/comment/share **counts** bundled free with each post.

**Cost trap:** `scrapeReactions` / `scrapeComments` are separate paid enrichments billed **per record** ($0.002 each) — used to get WHO reacted / comment text. A post with 1,500 reactions fully scraped ≈ $3. You almost never need this; counts come free. **Default both OFF.**

```json
{ "targetUrls": ["https://www.linkedin.com/in/<slug>/"], "maxPosts": 20, "scrapeReactions": false, "scrapeComments": false }
```
Output: `content` (text); `postImages.url` (+ width/height) and `header.image.url` (media); `engagement.likes/comments/shares`; `engagement.reactions.type`/`.count` (per-type breakdown); `postedAt.date`; `author.name`; `linkedinUrl`; `repostedBy.*` (reshares). Rows have `type` = `"post"` or `"reaction"`.
Projection: `fields: "type,content,postImages,header,engagement,postedAt,author,linkedinUrl,repostedBy"`
For comment TEXT (extra cost): `scrapeComments: true`, `maxComments: <n>`; or use `harvestapi/linkedin-post-comments`.

### apimaestro/linkedin-profile-posts (alternative) — $0.005/post
Flat per-post price, no enrichment add-ons, cleaner reaction fields, faster (~5s). Comment **count** only, never comment text.
```json
{ "username": "<slug>", "total_posts": 20 }
```
Output: `media.url`, `media.images.url`; flat `stats.total_reactions/like/love/insight/support/celebrate/funny/comments/reposts`; `posted_at.date`. Projection: `fields: "text,media,stats,posted_at"`

**Avoid `supreme_coder/linkedin-post`** — failed 3/3 in testing (proxy errors, then leaked session cookies into output; its "no cookies" claim is false).

---

## C — People search (find people by criteria)

### harvestapi/linkedin-profile-search
**Requires a one-time permission approval** (full account access). The call returns an approval URL — surface it to the user and stop; retry after they approve.

Pricing: $0.10 per search page (≤25 short profiles) + $0.004/full profile or $0.01/full + email.

Input: `searchQuery` (fuzzy), `currentJobTitles[]`, `currentCompanies[]` (company URLs), `locations[]`, `seniorityLevelIds[]`, `functionIds[]`, `industryIds[]`, `schools[]`, `recentlyChangedJobs`, `recentlyPostedOnLinkedIn`, `maxItems`, `profileScraperMode` (`"Short"` / `"Full"` / `"Full + email search"`).

Enums:
- **Seniority:** 110 Entry · 120 Senior · 130 Strategic · 200 Entry Mgr · 210 Exp Mgr · 220 Director · 300 VP · 310 CXO · 320 Owner/Partner
- **Function:** 8 Engineering · 10 Finance · 12 HR · 13 IT · 14 Legal · 15 Marketing · 18 Operations · 19 Product · 25 Sales

```json
{
  "searchQuery": "Chief Marketing Officer",
  "locations": ["United States"],
  "seniorityLevelIds": ["310"],
  "functionIds": ["15"],
  "maxItems": 10,
  "profileScraperMode": "Short"
}
```

---

## D — Company-employee lookup ("find the CMO at Best Buy")

### harvestapi/linkedin-company-employees
Anchored on a company; same filter set as C. **Also requires one-time permission approval.** Pricing: $0.02 start + $0.003 short / $0.008 full / $0.012 full+email per profile.

```json
{
  "companies": ["https://www.linkedin.com/company/best-buy"],
  "jobTitles": ["Chief Marketing Officer"],
  "seniorityLevelIds": ["310"],
  "profileScraperMode": "Short ($4 per 1k)",
  "maxItems": 5
}
```
Use D when the query is company-anchored ("who is the X at company Y"). Use C when criteria span companies.

---

## No single profile+posts actor
None returns profile details AND posts in one call. To get both, chain A + B. Budget two runs.

## Gotchas
1. **`publicIdentifiers` > `urls`** for harvestapi profile scraper (`urls` returned empty). Slug = last URL segment.
2. **Exact enum strings** for `profileScraperMode`, including the price suffix. Wrong string = validation error.
3. **Permission gates (C, D):** require a one-time `approvePermissions` grant. On the error, surface the approval URL and stop; retry after approval.
4. **Reaction/comment cost trap (B):** billed per record. Default both OFF; counts come free.
5. **Always project `fields=`** — profile actors return 130–230 columns.
6. **`get-dataset-items` approval gate** in some configs — the run still succeeded; approve or re-issue.
7. **PII:** prefer no-email modes; confirm lawful basis for third-party contact-data scraping.

## Defaults
Profiles → harvestapi `publicIdentifiers` no-email; dev_fusion when email/phone requested. Posts → harvestapi, reactions/comments OFF. Search (C) and employees (D) only after permission approval.
