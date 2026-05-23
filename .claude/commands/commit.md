---
description: Review changes and create clean git commits
---

# /commit - Git Commit Workflow

Review uncommitted changes and create logical, well-organized commits.

## Instructions

### 1. Check Current State
Run `git status` and `git diff --stat` to see all changes.

### 2. Group Changes
Identify logical groupings from the changes:

| Group | Files | Commit Type |
|-------|-------|-------------|
| Features/Scripts | `src/*.py`, `*.js` | `feat:` |
| Config | `CLAUDE.md`, `*.json` | `chore:` |
| Content | `content/`, `research/` | `content:` |
| State/Sessions | `state/`, `sessions/` | `chore:` |
| Docs | `*.md` (non-state) | `docs:` |

### 3. Create Commits
For each logical group, create a focused commit:

```bash
git add <relevant-files>
git commit -m "$(cat <<'EOF'
<type>: <short description>

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 4. Commit Order
1. Dependencies first (if B uses A, commit A first)
2. Features before docs
3. Content before state
4. **State/sessions always last**

### 5. Push (if requested)
After all commits are created:
```bash
git push
```

### 6. Verify
Show the commits created:
```bash
git log --oneline -5
```

## Commit Types

| Type | Use For |
|------|---------|
| `feat` | New features, scripts, integrations |
| `fix` | Bug fixes |
| `docs` | Documentation, setup guides |
| `content` | Blog posts, research, content files |
| `chore` | Config, maintenance, state updates |
