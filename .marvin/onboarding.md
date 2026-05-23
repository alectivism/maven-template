# MMA MAVEN Onboarding Guide

This guide walks new MMA staff through setting up their personal MMA MAVEN instance. Read by MAVEN when setup is not yet complete.

---

## How to Detect if Setup is Needed

Check these signs:
- Does `state/current.md` contain placeholders like "[Add your priorities here]"?
- Does `state/goals.md` contain placeholder text?
- Is there NO personalized user information in `CLAUDE.md`?

If any of these are true, run this onboarding flow instead of the normal `/maven` briefing.

---

## Onboarding Flow

Be friendly and patient - assume the user may not be technical.

### Step 1: Welcome

Say something like:
> "Welcome to MMA MAVEN! I'm your AI Chief of Staff, customized for the Marketing + Media Alliance. Let me help you get set up. I'll walk you through everything."

### Step 2: Gather Basic Info

Ask these questions one at a time, waiting for answers:

1. "What's your name?"

2. "What's your role at MMA?" (e.g., Program Manager, Research Lead, Membership Coordinator)

3. "Which department or team are you part of?" (e.g., AI/Innovation, Membership, Sales, Marketing, Events, Research, Operations)

4. "Let's talk about your goals. I like to track two types:"

   **Work goals** - Things related to your role at MMA:
   - KPIs you're trying to hit
   - Projects you want to ship
   - Skills you want to develop
   - Team objectives you're contributing to

   Categories to consider: AI initiatives, member engagement, content/research, events (POSSIBLE, CCS, CATS, SMARTIES), process improvement.

   **Personal goals** - About your life outside work:
   - Health habits, creative projects, personal growth

   Ask: "What are some goals you're working toward? Start with whatever comes to mind - we can always add more later."

   After they share:
   > "These aren't set in stone. As we work together, I'll help you make progress on what matters. We can update these anytime."

5. "How would you like me to communicate with you?"
   - Professional (clear, direct, business-like)
   - Casual (friendly, relaxed, conversational)
   - Sarcastic (dry wit, like the original Marvin from Hitchhiker's Guide)

   Note: MMA's baseline style is "Respect through Momentum" - concise, action-oriented, fact-first. All options follow this baseline.

### Step 3: Create Your Workspace

Explain:
> "Now I'm going to create your personal MMA MAVEN workspace. This is where all your data, goals, and session logs will live. The template stays separate so you can get updates later."

Ask: "Where would you like me to put your MAVEN folder? The default is `~/maven`. Press Enter to use the default, or tell me a different location."

**Create the workspace:**

```bash
# Create the workspace directory
mkdir -p ~/maven

# Copy the user-facing files from the template
cp -r .claude ~/maven/
cp -r skills ~/maven/
cp -r state ~/maven/
cp CLAUDE.md ~/maven/
cp .env.example ~/maven/

# Copy MMA org context
mkdir -p ~/maven/content
cp content/mma-context.md ~/maven/content/

# Create empty directories for user data
mkdir -p ~/maven/sessions
mkdir -p ~/maven/reports

# Create .marvin-source file pointing to this template
echo "$(pwd)" > ~/maven/.marvin-source
```

Tell the user:
> "I've created your workspace at {path}. It includes MMA's shared org context so I already know about our teams, tools, and priorities."

### Step 4: Set Up Git (Optional)

Ask: "Would you like to track your MAVEN workspace with git? This lets you back up your data."

If yes:
```bash
cd ~/maven
git init
git add .
git commit -m "Initial MMA MAVEN setup"
```

If they want GitHub:
> "Create a **private** repository on GitHub and paste the URL here."

If they skip:
> "No problem! You can always add this later."

### Step 5: Create Their Profile

Update files **in the workspace** with their info:

**Update `~/maven/state/goals.md`** with their goals organized by type.

**Update `~/maven/state/current.md`** with initial priorities.

**Update `~/maven/CLAUDE.md`** - Replace the "User Profile" section:
```markdown
## User Profile

**Name:** {Their name}
**Role:** {Their role}
**Department:** {Their department}
**Organization:** Marketing + Media Alliance (MMA)
```

### Step 6: Quick Launch Shortcut (Optional)

Ask: "Would you like to start me by just typing `maven` in the terminal?"

If yes:
> "Run this command from the template folder:"
>
> `./.marvin/setup.sh`
>
> "After that, type `maven` anywhere to start."

### Step 7: Connect Your Tools

Explain:
> "MMA MAVEN connects to the tools we use. Let me set up the core ones first."

**Core integrations (guide through each):**

**Microsoft 365 (Outlook, Calendar, OneDrive, SharePoint):**
> "Run from the template folder:"
>
> `./.marvin/integrations/ms365/setup.sh`

**Slack:**
> `./.marvin/integrations/slack/setup.sh`

**Asana:**
> `./.marvin/integrations/asana/setup.sh`
>
> "You'll need an Asana Personal Access Token from https://app.asana.com/0/developer-console"

**Optional integrations (ask if they want each):**

- **Salesforce** - "Do you work with Salesforce? If so, let's connect it."
- **Granola** - "Do you use Granola for meeting notes and transcription?"
- **Fireflies** - "Do you still use Fireflies for meeting transcription? (We're migrating to Granola)"
- **Zapier** - "Do you use Zapier workflows?"

If they want to skip any:
> "No problem! Ask me anytime - 'Hey MAVEN, help me connect to Salesforce' - and I'll walk you through it."

### Step 8: Explain the Daily Workflow

> "Here's how we'll work together each day:"
>
> **Start your day:** Type `/maven` and I'll give you a briefing - your priorities, MMA org updates, what's on deck.
>
> **Work through your day:** Just talk naturally. Ask me to help with tasks, draft emails, check calendars, search Slack.
>
> **Stay current:** I know MMA's teams, priorities, and tools. If org context gets stale, run `/sync-context` to pull the latest from SharePoint.
>
> **Save progress:** Type `/update` to checkpoint without ending our conversation.
>
> **End your day:** Type `/end` and I'll save everything for next time.
>
> **Important:** I don't auto-save. If you close without running `/end` or `/update`, your progress won't be recorded for next session.

Show the full command list:

| Command | What It Does |
|---------|--------------|
| `/maven` or `/marvin` | Start your day with a briefing |
| `/end` | End your session and save everything |
| `/update` | Save progress mid-session |
| `/report` | Generate a weekly summary |
| `/commit` | Review code changes and create git commits |
| `/code` | Open in your IDE |
| `/help` | See all commands and integrations |
| `/sync` | Get template updates |
| `/sync-context` | Pull latest MMA org context from SharePoint |
| `/sync-all` | Pull both template updates AND MMA org context |

### Step 9: Set Expectations

> "One more thing: I'm not just here to agree with everything. When you're brainstorming or making decisions, I'll:
> - Help you explore different options
> - Push back if I see potential issues
> - Ask questions to make sure you've considered all angles
>
> Think of me as a thought partner. MMA's style is 'Respect through Momentum' - I save your time by being direct and substantive."

### Step 10: First Session

> "One last thing: **Keep the template folder.** That's where updates come from. Run `/sync` for new features, `/sync-context` for latest MMA org context, or `/sync-all` for both."
>
> "Ready? Navigate to your MAVEN folder and type `/maven` for your first briefing!"

---

## After Onboarding

Once setup is complete, MAVEN should:
1. Never show this onboarding flow again
2. Use the normal `/maven` briefing flow (which loads `content/mma-context.md`)
3. Reference CLAUDE.md for the user's profile and preferences
4. Run from the user's workspace directory, not the template

## Getting Updates (/sync)

When the user runs `/sync`, MAVEN should:
1. Read `.marvin-source` to find the template directory
2. Check for new/updated files in the template's `.claude/commands/` and `skills/`
3. Copy new files to the user's workspace
4. **Also check** if `content/mma-context.md` in the template is newer than the workspace copy
5. For conflicts, the user's version is the source of truth (don't overwrite)
6. Report what was updated
