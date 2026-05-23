# Getting Started with MAVEN

**MAVEN** = MMA's Agentic Virtual Executive Navigator

Your AI assistant that knows MMA, connects to your tools, and remembers your work across sessions.

---

## What You Need

- **A Mac or Windows computer**
- **Your MMA Claude Team subscription** (sign in with your MMA email)
- **Your MMA credentials** for Outlook, Slack, and Asana

---

## Setup (15 minutes, one time)

### Step 1: Install Claude Code

**Mac:**
1. Open **Terminal** (press Cmd+Space, type "Terminal", press Enter)
2. Paste this and press Enter:
```
curl -fsSL https://claude.ai/install.sh | bash
```
3. Close and reopen Terminal

**Windows:**
1. Open **PowerShell** (search "PowerShell" in the Start menu)
2. Paste this and press Enter:
```
irm https://claude.ai/install.ps1 | iex
```
3. Close and reopen PowerShell

### Step 2: Download MAVEN

Paste this into your terminal and press Enter:
```
git clone https://github.com/alectivism/MAVEN.git ~/maven
```

> **Mac users:** If you see a popup asking to install "Command Line Developer Tools," click **Install**, wait for it to finish, then run the command again.

### Step 3: Run Setup

```
cd ~/maven && ./.marvin/setup.sh
```

The wizard walks you through your profile and tool connections.

### Step 4: Start MAVEN

```
maven
```

Type `/maven` to get your first daily briefing.

---

## Daily Usage

| What | How |
|------|-----|
| Start your day | Type `maven` in terminal, then `/maven` for a briefing |
| Ask for anything | Just talk: "Draft an email to...", "What's on my calendar?" |
| Save progress | Type `/update` |
| End your day | Type `/end` |
| Get help | Type `/help` |

---

## Getting Updates

When new features are available:
```
cd ~/maven
git pull
```

Your personal files are never overwritten.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "claude: command not found" | Close and reopen your terminal |
| "maven: command not found" | Run `cd ~/maven && ./.marvin/setup.sh` again |
| Popup about "Developer Tools" | Click Install, wait, then try again |
| Can't connect to Outlook/Slack | Ask MAVEN: "Help me set up Microsoft 365" |

---

## Need Help?

- Type `/help` inside MAVEN
- Ask on **#ai-upskilling** in Slack
- Contact Alec Foster
