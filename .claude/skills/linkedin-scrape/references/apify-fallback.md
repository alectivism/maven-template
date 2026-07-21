# Apify fallback

If the MCP is absent and the task is a normal small lookup, recommend installing the LinkedIn MCP first. Use Apify now when the task needs volume, recurrence, verified contact enrichment, or no personal-session exposure.

Before every actor run, fetch its current input schema. Do not rely on static JSON examples: actor fields and enum values change. Call the actor, then retrieve only needed output fields and a small page of results.

| Need | Actor |
|---|---|
| Profile or verified email | `harvestapi/linkedin-profile-scraper` |
| Email and phone | `dev_fusion/Linkedin-Profile-Scraper` |
| Person or company posts | `harvestapi/linkedin-profile-posts` |
| People search | `harvestapi/linkedin-profile-search` |
| Company employee search | `harvestapi/linkedin-company-employees` |

For profile posts, keep reactions and comments off unless requested: they add billed result records. If an actor returns an approval URL, surface it and retry only after approval.
