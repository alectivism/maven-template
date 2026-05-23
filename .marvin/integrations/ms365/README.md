# Microsoft 365 Integration

Connect Claude Code to Microsoft 365 (Outlook, Calendar, OneDrive, Teams, SharePoint, etc.)

## What It Does

- **Outlook** - Read, send, and manage emails
- **Calendar** - View and create events
- **OneDrive** - Access and manage files
- **Teams** - Read channels and messages
- **SharePoint** - Access sites and documents
- **To Do** - Manage tasks
- **OneNote** - Access notebooks
- **Planner** - View and manage plans

## Who It's For

Anyone using Microsoft 365 for work or personal productivity who wants Claude to help manage emails, calendar, and files.

## Prerequisites

- A Microsoft account (personal or work/school)
- Node.js installed (`npx` available)
- For work/school accounts: Your organization may require admin consent (see Troubleshooting)

## Setup

```bash
./.marvin/integrations/ms365/setup.sh
```

The setup script will prompt for:
- **Scope** — user-scoped (all projects) or project-scoped
- **Account type** — work/school or personal only
- **Tool preset** — all tools or essentials (mail, calendar, files)

## Authentication

Uses Microsoft's device flow authentication:
1. First request opens a browser prompt
2. Enter the device code shown
3. Sign in with your Microsoft account
4. Tokens are cached for future sessions

No API keys or client secrets required.

## Account Types

The `--org-mode` flag enables both:
- Work/School accounts (Microsoft 365 Business)
- Personal Microsoft accounts (outlook.com, hotmail.com)

## Try It

After setup, try these in Claude:

- "What's on my Outlook calendar today?"
- "Show my recent emails"
- "What files are in my OneDrive?"

## Danger Zone

This integration can perform actions that affect others or can't be easily undone:

| Action | Risk Level | Who's Affected |
|--------|------------|----------------|
| Send emails | High | Recipients see immediately |
| Delete emails | High | May be unrecoverable |
| Create/modify calendar events | Medium | Other attendees notified |
| Delete files | High | Data loss may be permanent |
| Read emails/files | Low | No external impact |

MARVIN will always confirm before performing high-risk actions.

## Troubleshooting

**"Failed to connect" error:**
- Run `claude mcp remove ms365 -s user` and re-run setup
- Make sure Node.js is installed

**Authentication issues:**
- Clear cached tokens by removing `~/.ms365-mcp/` directory
- Re-authenticate on next request

**"Need admin approval" error (Work/School accounts):**

This MCP requests broad permissions including Teams, SharePoint, and directory access. Many organizations require admin consent for these scopes.

Your options:
1. **Get admin consent** - Ask your IT admin to approve the app, or grant yourself admin rights if you're an admin
2. **Use a personal Microsoft account** - Personal accounts (outlook.com, hotmail.com) don't require admin consent
3. **Wait for a minimal-scopes version** - A fork with reduced permissions for just Mail, Calendar, and OneDrive is being considered

Scopes that typically require admin consent:
- `User.Read.All`, `Sites.Read.All`, `Files.Read.All`
- All Teams/Chat scopes (`Team.ReadBasic.All`, `Channel.ReadBasic.All`, etc.)

## Manual Setup

If you prefer to set up manually:

```bash
# Work/school account, all tools
claude mcp add ms365 -s user -- npx -y @softeria/ms-365-mcp-server --org-mode

# Work/school account, essentials only (may avoid admin consent)
claude mcp add ms365 -s user -- npx -y @softeria/ms-365-mcp-server --org-mode --preset mail,calendar,files

# Personal account only
claude mcp add ms365 -s user -- npx -y @softeria/ms-365-mcp-server
```

Available flags (run `--help` for full list):
- `--org-mode` — enable work/school accounts
- `--preset <tools>` — limit to specific tools (mail, calendar, files, teams, etc.)
- `--read-only` — disable write operations

## More Info

- **GitHub:** [softeria-eu/ms-365-mcp-server](https://github.com/softeria-eu/ms-365-mcp-server) — check here for latest flags and options
- **npm:** [@softeria/ms-365-mcp-server](https://www.npmjs.com/package/@softeria/ms-365-mcp-server)

To see all available options:
```bash
npx -y @softeria/ms-365-mcp-server --help
```

---

*Contributed by Deepak Ramachandran*
