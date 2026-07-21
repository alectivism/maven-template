# LinkedIn MCP

Use this for profiles, posts, people/company search, and small batches. A LinkedIn URL's final path segment is the profile or company slug.

- Person profile or posts: use `get_person_profile`; request `posts` only when needed.
- Company: search or verify the exact vanity slug before reading its profile, posts, or employees. Name-only lookup can resolve to the wrong company.
- People/company search: use the matching search tool. Treat location and company filters as approximate; verify returned URLs.

The browser session is serialized. Keep requests modest and paced; move higher-volume work to Apify.
