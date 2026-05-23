---
name: zapier-workflow-builder
description: Design Zapier workflows (Zaps) for MMA staff — architecture, troubleshooting, Copilot prompts. Use for "build a Zap", "Zapier help", or any automation Zapier could solve.
---

# Zapier Workflow Builder

Guide MMA staff through designing and building effective Zapier workflows. Your role is to help the user think through their automation need, design the right Zap architecture, and produce either step-by-step instructions or a Copilot prompt they can paste into Zapier to build it.

**Reference document:** The full MMA Zapier Guide with detailed setup instructions, API configurations, and HTML templates is on SharePoint: [Zapier Guide for MMA Staff](https://mmaglobalcom.sharepoint.com/:w:/s/MMAGlobal/IQCm1QQxv1p6TpXJAA4RAiMXAff-xU9YMMznmX_tykBFs-4?e=ypHORM). Point users there for detailed app-specific setup (Google Search API keys, Outlook HTML signatures, Salesforce field mappings, etc.).

---

## Workflow: Helping a User Build a Zap

### Step 1: Understand the Automation Need

Ask the user to describe what they want to automate. Clarify:

1. **The trigger event** — What starts this? (new email, form submission, schedule, transcript ready, spreadsheet row, RSS item, etc.)
2. **The desired outcome** — What should happen? (Slack notification, CRM update, email sent, task created, data logged, etc.)
3. **Conditions/filters** — Should it run every time, or only when specific criteria are met?
4. **Volume** — How often does this trigger fire? (determines task efficiency strategy)
5. **Apps involved** — Which apps need to connect? (Check if the user has access to shared connections in MMA's Zapier workspace)

### Step 2: Design the Zap Architecture

Based on the user's needs, design the workflow following these principles:

**Keep it lean:**
- Filter as step 2 (right after the trigger) — filters cost zero tasks and stop bad data early
- Use Formatter steps for data transformation — also zero task cost
- Only use AI or Code steps when Formatter can't handle it
- Use Digest by Zapier to batch high-volume triggers into periodic summaries

**Naming convention:**
```
[PREFIX] Trigger App: Event -> Action App: Result
```
Prefixes: `[MARKETING]`, `[MEMBERSHIP]`, `[SALES]`, `[OPS]`, `[EVENTS]`, `[DAILY]`, `[WEEKLY]`

**When to split into multiple Zaps:**
- More than 8 steps — hard to debug
- Unrelated actions for different teams
- Different parts need different error handling
- Reusable sequences — use Sub-Zaps instead

**When to keep as one Zap:**
- Linear logic (trigger + 2-5 sequential actions)
- All steps relate to the same business event
- Later steps need data from earlier steps

### Step 3: Present the Design

Show the user their Zap design as a numbered step list:

```
[MEMBERSHIP] Typeform: New Registration -> HubSpot + Slack

1. Trigger: Typeform — New Entry (form: "Event Registration")
2. Filter: Only continue if "Company Size" is not blank
3. Formatter: Split "Full Name" into First Name / Last Name
4. Action: HubSpot — Create Contact (map: first name, last name, email, company)
5. Action: Slack — Send Channel Message (#events-team: "{Name} from {Company} registered")
```

Include:
- Estimated tasks per run (only action steps count — triggers, filters, formatters, delays, paths, loops, sub-zap calls are free)
- Any shared connections they'll need (FullEnrich, Apollo, OpenAI are pre-shared in MMA's workspace)
- Potential issues or edge cases

### Step 4: Generate a Copilot Prompt

Zapier has a built-in AI assistant called **Copilot** that can build Zaps from natural language. It's available in the Zap editor (icon in lower left) and on Zapier's home page.

After designing the Zap, generate a structured Copilot prompt the user can paste directly into Zapier. Structure complex prompts with XML tags to prevent instruction bleed:

**Example Copilot prompt:**

```
<trigger>
New Typeform submission on the form "Event Registration"
</trigger>

<filter>
Only continue if the "Company Size" field is not blank
</filter>

<actions>
1. Use Formatter to split the "Full Name" field into First Name and Last Name (split on space, take first and last segments)
2. Create a contact in HubSpot with: First Name, Last Name, Email, Company Name, Company Size
3. Send a message to the Slack channel #events-team with the text: "[First Name] [Last Name] from [Company Name] just registered for [Event Name]"
</actions>
```

**Copilot prompting tips:**
- Use consistent field names throughout — if you say "Company Size" once, keep calling it that
- Frame positively: "Send notifications Monday through Friday" not "Don't send on weekends"
- Be specific about apps — vague prompts produce generic results
- For simple Zaps, one-liners work: "When a new Typeform response comes in, add the person to HubSpot and send a Slack message to #membership"
- Iterate — keep the conversation going with Copilot to refine steps rather than starting over
- Copilot can also accept voice input and image/sketch attachments

**Copilot limitations:**
- Won't connect app accounts — users still authenticate each app themselves
- Complex field mappings often need manual refinement after the draft is built
- Always test after building — Copilot can't predict trigger behavior

### Step 5: Provide Setup Guidance

Walk the user through any configuration that Copilot won't handle:
- App authentication (point to shared connections in MMA's workspace where available)
- Filter conditions and field mapping verification
- Testing each step with real data
- Renaming steps descriptively (e.g., "AI by Zapier" -> "Extract CMO name and company from article")
- Version naming before publishing (e.g., "2026-03-20: initial setup for event registration")

---

## Task Cost Reference

Understanding what counts as a task prevents billing surprises:

| Component | Costs a Task? |
|-----------|:---:|
| Trigger firing | No |
| Filter step | No |
| Formatter step | No |
| Delay step | No |
| Path step (branching) | No |
| Looping step (the loop itself) | No |
| Sub-Zap call step | No |
| Digest step | No |
| Storage / Tables step | No |
| Each action step that completes | **Yes** |
| Each loop iteration's actions | **Yes** |
| AI by Zapier | **Yes** |
| Code by Zapier | **Yes** |
| Webhooks by Zapier | **Yes** |

**Cost optimization rule:** Put filters and formatters before action steps. A 5-step Zap (1 trigger + 1 filter + 1 formatter + 2 actions) costs only 2 tasks per run.

---

## Common MMA Patterns

### Lead Capture + Enrichment
```
Trigger: Form submission (Typeform/Gravity Forms)
-> Filter: Company field is not blank
-> Action: FullEnrich — Enrich contact (shared connection available)
-> Action: Create/update HubSpot or Salesforce contact
-> Action: Slack notification to #sales with lead summary
```
**Copilot prompt:** "When a new Typeform submission comes in on [form name], enrich the contact email using FullEnrich, then create a contact in HubSpot with the enriched data, and send a summary to #sales on Slack"

### Meeting Recap Automation
```
Trigger: Fireflies — New transcript
-> Filter: Participants contain yourname@mmaglobal.com
-> Code: Extract external attendee emails (filter out @mmaglobal.com and notetaker domains)
-> AI: Summarize key decisions and action items
-> Action: Post summary to Slack DM or channel
-> Action: Create Asana tasks for action items
```

### CMO News Monitoring
```
Trigger: RSS by Zapier — Google News RSS feed
-> Filter: Exclude blacklisted publishers
-> AI: Extract CMO name, company, appointment details from article
-> Action: Log to Google Sheets or Zapier Tables
-> Action: Slack notification to #sales
```
*Refer user to the SharePoint guide for Google News RSS feed setup and search operators.*

### Automated Email Sequences with Human Review
```
Trigger: New CRM contact or scheduled
-> AI: Draft personalized email
-> Action: Slack "Request Approval" with draft preview
-> Path A (Approved): Send via Outlook
-> Path B (Rejected): Log and stop
```

### Weekly Digest / Reporting
```
Trigger: Schedule — Every Monday at 9 AM
-> Action: Pull data from Google Sheets/Airtable
-> Formatter: Format dates and numbers
-> Action: Send compiled email or Slack message
```

---

## Error Handling

### For Critical Zaps (lead capture, member data, outreach)
Add an error handler on action steps: click the three dots on any step -> "Add error handler" -> send a Slack message with error details to the owner.

**Important tradeoff:** Zaps with custom error handlers will NOT use Autoreplay (automatic retry). Choose one per Zap:
- **Autoreplay** — best for transient failures (API timeouts, rate limits). Retries up to 3 times automatically.
- **Error handlers** — best when you need immediate notification or alternate logic on failure.

### For Non-Critical Zaps
Rely on Zapier's default email notifications for errors.

### Avoiding Loops
A Zap loop happens when Zap A triggers Zap B which triggers Zap A. Prevention:
- Add a guard field (e.g., `processed_by_zap = true`) and filter on it
- For Google Sheets: use "Trigger Column" to only fire on specific column changes
- Never have two Zaps that read/write the same data without loop guards

---

## AI Steps: When to Use What

| Need | Use This | Why |
|------|----------|-----|
| Summarize text, draft emails, extract info | AI by Zapier (GPT-5 Mini) | Free model, customizable inputs/outputs |
| Web search within a Zap | ChatGPT/Gemini/Claude/Perplexity app | AI by Zapier can't search the web |
| Conversation memory across steps | ChatGPT app with Conversation ID | AI by Zapier has no memory between steps |
| Predictable logic (date math, email parsing, URL cleaning) | Code by Zapier | Code never hallucinates — use for deterministic transforms |
| Data formatting (split names, reformat dates, lookup tables) | Formatter by Zapier | Zero task cost, handles most transformations |

**AI by Zapier model selection:**
- **GPT-5 Mini** (free, no API key) — suitable for 80% of tasks
- **Gemini 2.5 Flash Lite** (free, no API key) — alternative free option
- **GPT-5.2** (requires shared OpenAI connection) — use only for heavy reasoning or high-stakes data

MMA has shared OpenAI connections for each region. Select "Zapier-provided" credentials for the free models.

---

## Code by Zapier: No Coding Required

Users don't need to write code themselves. Two approaches:

**Option A — Zapier Copilot (fastest):** Click "Generate with AI" inside the Code step and describe what you need. Copilot writes the code and maps variables automatically.

**Option B — External AI (fallback):** Ask Claude/ChatGPT to write the code, then paste it into the Code step. Always specify: "Write a Zapier JavaScript code block" and describe input variable names and expected outputs.

**When to suggest Code over AI:**
- Splitting email lists into internal/external (deterministic, no hallucination risk)
- Calculating business days (date math needs precision)
- URL/domain extraction (parsing logic, not interpretation)
- Any transform where the answer must be exactly right every time

---

## Testing Checklist

Before turning on any Zap:

1. **Test the trigger** with real data (not just the default sample)
2. **Test each action** — remember, action tests are live (they create real records, send real messages). Use test data where impact is reversible.
3. **Run end-to-end** using "Test run" (top right of editor) on a selected record
4. **Check edge cases:** records with blank optional fields, unusual characters, conditions that should halt the Zap
5. **Rename every step** descriptively — makes debugging dramatically faster
6. **Name the version** before publishing (this is your changelog)
7. **Monitor Zap History** after the first few live runs — filter by "Errored" to catch issues early

**Debugging workflow:**
1. Open Zap History -> filter by "Errored"
2. Click the failed run -> see which step failed
3. Click "Troubleshoot" tab — Zapier's built-in AI generates specific fix instructions
4. Click "Logs" tab for raw HTTP details if needed
5. Fix, re-test the step, re-publish

---

## Folder Organization

MMA's Zapier workspace uses this structure:
```
MMA Zaps/
+-- Marketing/
|   +-- Lead Capture
|   +-- Social & Content
+-- Membership/
|   +-- Onboarding
|   +-- Renewals
+-- Events/
+-- Operations/
|   +-- Reporting
|   +-- Notifications
+-- _Archive/
+-- MMA TEMPLATES (DO NOT EDIT - duplicate to use)
```

**Template usage:** Duplicate templates, never edit originals. Click the workflow name -> "Duplicate" -> rename -> move out of MMA TEMPLATES folder.

---

## Quick Reference

| Goal | Tool/Approach |
|------|---------------|
| Stop Zap early without error | Filter (step 2) |
| Transform data format | Formatter (free) |
| Run action on each list item | Looping by Zapier |
| Reuse steps across Zaps | Sub-Zaps |
| Handle failures gracefully | Error Handler on step |
| Retry failed runs automatically | Autoreplay |
| Batch notifications | Digest by Zapier |
| Instant triggers (no polling) | Webhooks by Zapier |
| Process historical data | Transfer |
| Build from description | Copilot |
| Debug failures | Zap History -> Troubleshoot tab |
| Branch to different actions | Paths (if/else) |

---

## Resources

- **MMA Zapier Workspace:** [Sign up form](https://forms.office.com/r/paFNryZc1v)
- **Full MMA Zapier Guide (SharePoint):** [Zapier Guide for MMA Staff](https://mmaglobalcom.sharepoint.com/:w:/s/MMAGlobal/IQCm1QQxv1p6TpXJAA4RAiMXAff-xU9YMMznmX_tykBFs-4?e=ypHORM) — detailed setup for Google Search API, Outlook HTML signatures, Salesforce, FullEnrich, Apollo, Webhooks, and more
- **MMA Zap Template Library (Excel):** Available in MMA's Zapier workspace
- **Zapier University:** Short video courses (start with "Zapier 101")
- **Zapier Blog:** Search for app-specific recipes and templates
