# Slack Integration

Connect MARVIN to your Slack workspace.

## What It Does

- **Read messages** - View channel history, search conversations
- **Send messages** - Post to channels and threads
- **Search** - Find messages across your workspace
- **Channels** - List and browse public/private channels

## Who It's For

Teams that use Slack for communication and want MARVIN to help search through conversations, track discussions, or post updates.

## Prerequisites

- A Slack workspace where you have permission to create apps
- Admin approval may be required for some workspaces

## Setup

```bash
./.marvin/integrations/slack/setup.sh
```

The script will guide you through:
1. Creating a Slack App in your workspace
2. Adding the required permissions (OAuth scopes)
3. Installing the app and getting your token
4. Configuring the MCP server

## Required Slack Permissions

The setup script will ask you to add these User Token Scopes:

| Scope | What It Allows |
|-------|----------------|
| `channels:history` | Read messages in public channels |
| `channels:read` | View basic channel info |
| `chat:write` | Send messages |
| `groups:history` | Read messages in private channels |
| `groups:read` | View private channel info |
| `im:history` | Read direct messages |
| `im:read` | View DM info |
| `mpim:history` | Read group DMs |
| `mpim:read` | View group DM info |
| `search:read` | Search messages |
| `users:read` | View user info |

## Try It

After setup, try these commands with MARVIN:

- "List my Slack channels"
- "Search Slack for meeting notes from last week"
- "Show recent messages in #engineering"
- "What's been discussed about the API migration?"
- "Send a message to #general saying 'Good morning team!'"

## Multiple Workspaces

You can connect multiple Slack workspaces by running the setup script again and choosing a different server name (e.g., `slack-work`, `slack-personal`).

## Danger Zone

This integration can perform actions that affect your team:

| Action | Risk Level | Who's Affected |
|--------|------------|----------------|
| Send messages | **High** | Team members see it immediately |
| Read messages, search | Low | No external impact |

**MARVIN will always confirm before sending messages.**

## Troubleshooting

**"Invalid token" errors**
- Make sure you copied the **User OAuth Token** (starts with `xoxp-`), not the Bot token
- Check that the app is installed to your workspace

**Missing channels**
- The app can only see channels you have access to
- For private channels, you must be a member

**Can't send messages**
- Ensure the `chat:write` scope is added
- You can only post to channels you're a member of

**Permission denied**
- Some workspaces require admin approval for new apps
- Check with your Slack admin

## MCP Server

This integration uses [slack-mcp-server](https://github.com/korotovsky/slack-mcp-server) by korotovsky.

---

*Contributed by Peter Vanhee*
