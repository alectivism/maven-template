---
description: Show available commands, skills, and integrations
---

# MARVIN Help

## Commands

| Command | What It Does |
|---------|-------------|
| `/marvin` | Start your session — loads context, gives you a briefing |
| `/end` | End session — saves everything to your session log and state |
| `/update` | Quick save — checkpoint without ending |
| `/report` | Generate a weekly summary of your work |
| `/commit` | Review and commit git changes |
| `/code` | Open MARVIN in your IDE (Cursor or VS Code) |
| `/help` | Show this help screen |
| `/sync` | Sync MARVIN skills and rules to the MAVEN template |

## Skills (MMA-Specific)

MARVIN has specialized skills that activate automatically or can be invoked directly. Here's what's available:

### Writing & Content
| Skill | What It Does | Try Saying |
|-------|-------------|------------|
| `email-draft` | Draft emails in MMA voice with proper formatting | "Write an email to the membership team about..." |
| `content-draft` | Blog posts, newsletters, one-pagers, thought leadership | "Draft a blog post about CAP results" |
| `social-post` | LinkedIn posts optimized for MMA's audience | "Create a LinkedIn post promoting POSSIBLE" |
| `event-promo` | Promotional content for POSSIBLE, CMO Summit, SMARTIES, etc. | "Write an invitation for CATS" |
| `member-comms` | Member-facing communications (onboarding, renewals, updates) | "Draft a renewal email for MarTech members" |

### Meetings & Collaboration
| Skill | What It Does | Try Saying |
|-------|-------------|------------|
| `meeting-followup` | Segmented follow-up emails after meetings | "Write follow-up emails for today's ALTT meeting" |
| `briefing-prep` | Prep for upcoming meetings with attendee info and context | "Prep me for my call with [Name]" |
| `slack-summary` | Summarize Slack channel activity | "What happened in #cap this week?" |

### Research & Think Tanks
| Skill | What It Does | Try Saying |
|-------|-------------|------------|
| `research` | Web research with structured findings | "Research the latest on AI in advertising" |
| `lab-summary` | Summarize Future Lab results for any audience | "Write up CAP results for the board" |
| `research-brief` | Format think tank findings into briefs | "Create a MATT update for the newsletter" |
| `case-study` | Draft case studies from lab or program results | "Write a case study on Kroger's CAP results" |

### Operations
| Skill | What It Does | Try Saying |
|-------|-------------|------------|
| `asana-task` | Create and manage Asana tasks | "Create a task for the POSSIBLE planning project" |
| `sharepoint-find` | Find documents across MMA's SharePoint sites | "Find the brand kit on SharePoint" |

### Session Management
| Skill | What It Does |
|-------|-------------|
| `content-shipped` | Automatically logs completed deliverables |
| `daily-briefing` | Generates your morning briefing |
| `skill-creator` | Create new custom skills |

## Integrations

MARVIN can connect to these tools (run the setup script to configure):

| Integration | What You Can Do |
|-------------|----------------|
| **Outlook** (MS365) | Read/send email, manage calendar, search SharePoint |
| **Slack** | Read channels, search messages |
| **Asana** | Create/update tasks, search projects |
| **Salesforce** | Look up member info, pipeline data |
| **Web Search** | Research any topic online |

## Tips
- Start each day with `/marvin` for a briefing
- Use `/update` frequently to save progress
- Always end with `/end` so context carries over
- Skills activate automatically — just describe what you need
- Say "remember [something]" to add it to your CLAUDE.md
