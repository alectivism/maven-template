# Safety Rules

## Destructive Commands — Require Explicit Confirmation

Never run these without stating what the command does, what data could be lost, and receiving explicit approval:

- **File deletion:** `rm -rf`, `rm -r`, `find ... -delete`
- **Git destructive ops:** `git push --force`, `git push -f`, `git reset --hard`, `git clean -f`, `git checkout .`, `git restore .`, `git branch -D`
- **Permissions:** `chmod -R 777`
- **Database destructive ops:** `DROP TABLE`, `DELETE FROM` without `WHERE`, `TRUNCATE`
- **Process killing:** `kill -9` on system processes
- **Any command that permanently deletes data or is irreversible**

Before running any of the above:
1. State exactly what the command will do in plain English
2. Explain what data could be lost
3. Wait for explicit "yes" or approval — do not proceed without it

Prefer safe alternatives when possible (e.g., `git stash` over `git reset --hard`, moving files to trash over `rm -rf`).

## Secrets Protection

- Never echo or print `.env` file contents
- Never include API keys, tokens, or credentials in outputs, logs, or commit messages
- Never write credentials to files outside `.env`
- Never commit `.env` files to git

## Clarity for Non-Technical Users

- If a command might be confusing, explain what it does before running it
- When multiple approaches exist, prefer the safer one and explain why
