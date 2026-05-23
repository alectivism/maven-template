# {{ORG_NAME}} Organization Context

> **Setup status:** {{SETUP_STATUS}}
> Run `/onboard` to populate this file. Until then, Claude will work without org context.

Last updated: {{LAST_UPDATED}}

---

## About {{ORG_NAME}}

{{ORG_ONE_LINER}}

{{ORG_LONG_DESCRIPTION}}

**Key facts** (replace each with your own):
- Type: {{ORG_TYPE}} <!-- nonprofit / B-corp / privately-held / public / agency / etc. -->
- Headcount: {{HEADCOUNT}}
- Locations: {{LOCATIONS}}
- Members / customers / users: {{CONSTITUENCY}}
- Founded: {{FOUNDED_YEAR}}
- CEO / founder: {{LEADER_NAME}}

---

## Teams & Key Staff

<!--
List the departments, leaders, and one-line focus for each.
This helps Claude know who does what when you ask about colleagues, who to loop in,
or who to draft messages for.
-->

| Department | Key People | Focus |
|------------|-----------|-------|
| {{DEPT_1_NAME}} | {{DEPT_1_LEADS}} | {{DEPT_1_FOCUS}} |
| {{DEPT_2_NAME}} | {{DEPT_2_LEADS}} | {{DEPT_2_FOCUS}} |
| {{DEPT_3_NAME}} | {{DEPT_3_LEADS}} | {{DEPT_3_FOCUS}} |

---

## Programs / Products / Workstreams

<!-- List the major things your org runs, ships, or supports. -->

- **{{PROGRAM_1_NAME}}** — {{PROGRAM_1_DESCRIPTION}}
- **{{PROGRAM_2_NAME}}** — {{PROGRAM_2_DESCRIPTION}}
- **{{PROGRAM_3_NAME}}** — {{PROGRAM_3_DESCRIPTION}}

---

## Acronyms & Terminology

<!--
List internal acronyms and how they should be expanded.
Helps Claude use the right names instead of guessing.
-->

- {{ACRONYM_1}} — {{ACRONYM_1_EXPANSION}}
- {{ACRONYM_2}} — {{ACRONYM_2_EXPANSION}}

---

## Data & Security Rules

<!--
Replace these with your org's actual rules. Examples below are reasonable defaults.
-->

- **Confidential data** → Approved secure tools only. Never in public AI tools.
- **PII, financials, contract terms** → Never in templates or AI tools without explicit clearance.
- **Credentials** → Never shared via email or Slack. Use 2FA everywhere.
- **Research / unreleased work** → Embargoed until official release.
- **Board materials** → Authorized recipients only.
- **Template sanitization** → Use placeholders (`{{CUSTOMER_NAME}}`, `{{CONFIDENTIAL_SUMMARY}}`), never real data when sharing externally.

---

*Maintained by {{YOUR_NAME}}. Edit this file directly or run `/onboard` to walk through it interactively.*
