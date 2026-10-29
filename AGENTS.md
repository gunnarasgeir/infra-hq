# infra-hq

This repository is the user's **infrastructure HQ**. It holds everything an AI coding agent needs to operate the user's servers, domains, DNS, hosting, databases and other services on their behalf: how to reach each service, what is running where, the rules to follow, and a history of changes.

You are that agent. The user asks you to do things ("move this site to my VPS", "clean up old DNS records", "is my database backed up?"), and you do them, safely.

This file is read by every agent (Claude Code via `CLAUDE.md`, Gemini CLI and Antigravity via `GEMINI.md`, Codex and others directly). Everything here applies regardless of which agent you are.

## At the start of every session

1. Run `git pull` and `git status`. The user may work from several computers and several agents.
2. Decide which mode you are in:

| Situation | Mode | Do this |
|---|---|---|
| `docs/infrastructure.md` does not exist | **Onboarding** | Follow `docs/onboarding.md`. Start by talking to the user. |
| The user says something like "connect this computer" or "set up this machine" | **New machine** | Follow `docs/machine-setup.md`. |
| Otherwise | **Normal** | Read `docs/infrastructure.md` before answering questions about a specific site, app or service. |

3. Speak the user's language (see **This setup** below). Files in this repo are written in the language recorded there.

## Where things live

| Path | Contents | Personal or generic |
|---|---|---|
| `AGENTS.md` | This file. Rules for every agent. The **This setup** section at the end is personal. | Both |
| `docs/infrastructure.md` | What is running where: domains, DNS, servers, apps, databases, backups, and which GitHub repo deploys to which app. | Personal |
| `docs/machine-setup.md` | How to connect a new computer to all of the user's services. | Personal |
| `docs/todo.md` | Open tasks, ideas and problems found. | Personal |
| `history/` | Backups of settings taken **before** they were changed, plus a change log. | Personal |
| `services/` | One recipe per service type: how to connect, minimal key permissions, how to test, known pitfalls. | Generic |
| `playbooks/` | Step-by-step guides for common jobs (moving hosting, DNS cleanup, backup audit). | Generic |
| `scripts/` | Key management and helpers. `scripts/keys.conf` lists which keys this setup uses (names only). | Generic |
| `templates/` | Skeletons used during onboarding. | Generic |

## Rules

These apply always, in this repo and in every other repo of the user's (see **Other repositories**).

### Keys and secrets
- **Never ask for keys, tokens or passwords in the chat.** Never print them, never echo them, never write them into a file in this repo. If you see one by accident, never repeat it.
- The user stores keys with `scripts/set-key.sh` (macOS/Linux) or `scripts\set-key.cmd` (Windows), **with the agent closed**, because agents display file changes and terminal input. Keys become environment variables in new terminals.
- Commands that prompt for a password (`sudo`, `gh auth login`, NAS admin login) are run by the user, not by you.
- Prefer least-privilege keys. When a key is missing or lacks a permission, tell the user exactly which permission to add and where (see `services/<name>.md`), and point to `scripts/set-key.*`.
- **APIs sometimes return secrets** (connection strings, generated passwords). Filter responses before they reach the chat, e.g. `| python3 -c "import sys,json; print(json.load(sys.stdin)['id'])"`.
- **Never pipe a secret into something that executes stdin as a script** (e.g. `ssh host "bash -c \"\$(cat)\""`). If the script fails, the secret is executed as a command and shows up in error messages. Copy the script to the server first, then run it with the secret on stdin.

### Confirm first
Ask the user before you:
- delete anything (records, apps, databases, volumes, files, branches, projects),
- change DNS on a live domain, or change email-related records (MX, SPF, DKIM, DMARC),
- stop, restart or redeploy anything listed as production in `docs/infrastructure.md`,
- change access control that could expose something private, or lock the user out,
- change firewall rules, reboot or resize a server,
- spend money (buying domains, upgrading plans, enabling paid features).

Reading, listing and inspecting are always fine. When in doubt, ask.

### Safety nets
- **Back up before you change.** Before changing or deleting DNS records, access rules, firewall rules or other settings, save the current state to `history/` as `YYYY-MM-DD-<description>.json` (or `.yaml`, etc.) and add an entry to `history/README.md`. Strip secrets from backups.
- **Never delete data permanently.** Move it aside instead (e.g. `_removed-YYYY-MM-DD/`), or give the user the command to run themselves once you have confirmed it is safe.
- **Offer a snapshot** before big server changes (OS or platform upgrades, Docker or disk changes), if the provider supports it.
- **Test before switching.** When moving a site, verify the new host serves it correctly before changing DNS (e.g. `curl --resolve domain:443:<new-ip> https://domain/`). Keep the old host running until the user confirms the move.

### Keep the repo true
- **Update `docs/infrastructure.md` in the same step** as any change to domains, apps, servers, access rules or services.
- Add newly discovered problems and ideas to `docs/todo.md`, and tick them off when done.
- **Commit and push after every change** to infrastructure or docs, with a clear message.
- **Everything that matters goes into this repo, not into the agent's local memory.** The user may switch computers, accounts or agents, and only the repo follows them.
- When you learn something about a service that would help anyone (a pitfall, a better command), add it to `services/<name>.md`. If no recipe exists for a service, write one from `services/_template.md`.

## Other repositories

The user's other repos (websites, apps) each describe their own code. This repo describes the infrastructure they run on. During onboarding, a short pointer to this file is installed in each agent's global instructions (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`), so the rules above apply in every repo. When you work in another repo:
- Paths like `docs/infrastructure.md` and `scripts/` refer to **this** repo, not the current one.
- Run `git -C <this repo> pull` before reading or changing docs here.
- If you change or learn anything about the infrastructure (DNS, hosting, env vars, access), update **this** repo and commit and push here, not in the other repo.
- The other repo's own instructions apply to its code.

## Pulling updates from the template

This repo was created from the public template `gunnarasgeir/infra-hq`. To bring in improvements (new service recipes, playbooks, fixes):

```bash
git remote add template https://github.com/gunnarasgeir/infra-hq.git   # once
git fetch template
git diff HEAD template/main -- services/ playbooks/ scripts/ templates/ docs/onboarding.md AGENTS.md
```

Merge the generic parts by hand and show the user what changed. **Never** take `docs/` (other than `onboarding.md`), `history/`, `scripts/keys.conf`, the README or the **This setup** section from the template.

---

## This setup

<!-- Personal section. Filled in during onboarding (docs/onboarding.md). Keep it short: it is loaded in every session, in every repo. -->

_Not set up yet. Follow `docs/onboarding.md`._
