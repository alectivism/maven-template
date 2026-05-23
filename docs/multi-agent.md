# Multi-Agent Workflows

Three patterns for running multiple agents from a single Claude Code session.

## 1. Subagents (parallel research / Q&A)

Use the `Agent` tool to dispatch a focused task to a subagent. The subagent runs in its own context, returns a result, and you keep working in the main thread.

Best for:
- Parallel research where you need 3-5 sources gathered simultaneously
- Long file reads that would burn main-context tokens
- Domain-specific work where you want a specialized agent type

In your session, just say:
> "Spawn a research subagent to find X and Y in parallel. Come back when done."

Or invoke directly via the `Agent` tool. Available subagent types depend on your installed agents — check the spawn dropdown or your team's agent registry.

## 2. Worktrees (parallel branches, isolated changes)

Run multiple Claude Code instances against different branches of the same repo without conflict. Each worktree gets its own working directory and branch.

```bash
# From your repo root:
git worktree add ../myrepo-experiment-1 -b experiment/feature-a
git worktree add ../myrepo-experiment-2 -b experiment/feature-b
```

Then open each in its own terminal + Claude Code session. Both can run simultaneously without stepping on each other.

When you're done with a worktree:
```bash
git worktree remove ../myrepo-experiment-1
```

Best for:
- Comparing two implementations of the same feature
- Trying a refactor while keeping main work going
- "Run this risky change in isolation and let me review the diff"

## 3. Teams (orchestrated agents with persistent state)

Enable experimental agent teams in your Claude Code settings:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

This unlocks the team primitive — a group of subagents that can be addressed by name, kept warm between turns, and orchestrated through `SendMessage`. Think of a team like a Slack channel where each member is a Claude with a specific focus.

Best for:
- Long-running multi-step builds where you want named specialists
- "Wake the test-writer when the build fails, ping the code-reviewer when tests pass"
- Pipelines with clear handoffs

## 4. Background commands (poll-and-notify)

For waiting on long-running processes (builds, deploys, polls), use Bash with `run_in_background: true` instead of synchronous waits. You get a notification when it finishes; in the meantime, do other work.

```bash
# In Claude Code, ask for a background command like:
"Start the build and let me know when it's done."
```

## 5. Cron / scheduled wake-ups

For tasks that should run at a specific time (or repeatedly), use `/schedule` to create a CronCreate job. Claude Code wakes itself up at the scheduled time and runs the task — useful for daily briefings, weekly summaries, or "ping me in 30 minutes if the deploy hasn't finished."

---

## Picking the right pattern

| Need | Pattern |
|---|---|
| Read 5 sources in parallel | Subagents |
| Compare two refactors | Worktrees |
| Persistent specialists with handoffs | Teams |
| Wait for a long build | Background command |
| Run something daily/weekly | Cron |

Most days you'll only use subagents and worktrees. Teams are for big projects. Cron is for habits.

---

## Tips

- **Don't overuse subagents.** Each one spends tokens. If a task is short and synchronous, just do it in the main thread.
- **Don't run more than 3 worktrees against one repo simultaneously.** You'll lose track.
- **Read [Claude Code docs on agents](https://docs.claude.com/claude-code/agents)** for the current syntax — the API evolves.
