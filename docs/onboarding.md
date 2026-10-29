# Onboarding

> **For the agent.** You are in onboarding mode because `docs/infrastructure.md` does not exist yet. Your job is to turn this empty template into the user's infrastructure HQ: understand what they have, connect to it with enough access to do real work (but nothing it does not need), map it, and write it down.
>
> **Assume nothing except GitHub.** The user may host on a VPS, a PaaS, shared hosting, a NAS at home, or all of them. They may use Cloudflare, their registrar's DNS, or something you have never heard of. Ask, then adapt.
>
> Work in phases. Finish each one, tell the user where you are, and commit as you go. The whole thing can take one long session or several short ones. If you stop midway, record progress in `docs/todo.md` under "Onboarding" so the next session can continue.

## Phase 0: Safety check

1. `gh auth status`. If GitHub CLI is missing or not logged in, help the user install it and ask them to run `gh auth login` themselves (it opens a browser).
2. `gh repo view --json nameWithOwner,visibility`. **This repo must be private.** It will contain domain names, server addresses, account IDs and the map of everything the user owns. If it is public, stop and help the user make it private (`gh repo edit --visibility private --accept-visibility-change-consequences`, after they confirm) before anything else.
3. Note the OS (`uname -a` or `$PSVersionTable`) and the absolute path of this repo. You will need both.

## Phase 1: Conversation

Explain briefly what is about to happen: *"I'll ask about what you run and what you want to be able to ask me to do. Then I'll help you create access keys with only the permissions needed, check that everything works, map your setup and write it down. Keys never go through this chat."*

Then ask. **A few questions at a time, conversationally**, not a long form. Follow up on what they say. Skip what does not apply.

**About the user**
- What should I call you? What do you do, and what is all this infrastructure for (business, side projects, family)?
- Which language do you want me to speak, and which language should the docs in this repo be written in?
- Which computers do you work from (OS)? Which AI coding agents do you use (Claude Code, Codex, Gemini CLI, Antigravity, Cursor, ...)?
- Where do you keep passwords (password manager)? Keys we create should be saved there too.

**What they have.** Let them talk, then fill gaps:
- **Domains:** which ones, where are they registered, where is DNS managed?
- **Websites and apps:** what are they, where are they hosted, which GitHub repo is each built from? Which are production?
- **Servers:** VPS, dedicated, home server or NAS? Provider, and how do they log in today?
- **Platforms:** Coolify, Dokku, CapRover, Kubernetes, cPanel, Plesk, ...?
- **Databases and storage:** managed (Supabase, Neon, PlanetScale, RDS, ...) or self-hosted? Object storage (S3, R2, B2)?
- **Email:** who handles mail for their domains? (Mail records are high-risk. Treat them with extra care.)
- **Backups:** what is backed up, where, and has a restore ever been tested?
- **Other services** that matter: auth, analytics, payments, CDN, monitoring, password-protected admin pages, ...

**What they want**
- What would you like to be able to just ask me to do? Offer examples: *move a site from one host to another, clean up old DNS records, deploy or roll back, check why something is down, set up a new site with HTTPS, protect a page behind a login, check that backups work, see what everything costs.*
- How much access are you comfortable with? Read-only to start, or full access with confirmation before risky steps? (Default: full access to what they want managed, **read-only** for anything they are unsure about.)

**What is precious**
- Is there anything critical or fragile that I should be extra careful with, or never touch without asking? (A database with irreplaceable data, a client's site, a NAS with family photos, ...)
- Anything I should never do at all?

Summarize what you heard in a short table (service, what it is used for, how much access) and ask the user to confirm or correct it.

## Phase 2: Access plan

**Enough access to do the job.** The goal is an agent that can actually do what the user asks, not a read-only observer. Size each key by *what the user wants to be able to ask for* (Phase 1) and give it write access for all of that. Make it smaller by leaving out what no task needs: billing and payments, deleting the account, managing other users and tokens, and admin or root scopes that can read every secret. When unsure about a permission that serves a task the user listed, include it. A key that is too narrow sends the user back to the dashboard mid-task; a key that is too broad is a risk. Day-to-day safety comes from the rules in `AGENTS.md` (confirm first, back up, never delete for good), not from crippled keys.

For each service in the confirmed list:

1. Look for a recipe in `services/`. If there is none, research the provider's official API and CLI documentation and **write a new recipe** from `services/_template.md`: how to authenticate, which key permissions cover typical tasks (and which to leave out), a read-only test command, and known pitfalls. Recipes are generic: no personal domains, IDs or IPs in them.
2. Prefer, in this order: an official CLI or REST API with a scoped token, then SSH with a key, then an MCP server. CLI, API and SSH work with every agent. MCP servers are optional extras.
3. For each key, decide the **environment variable name** (follow the provider's convention, e.g. `CLOUDFLARE_API_TOKEN`, `HCLOUD_TOKEN`, `DIGITALOCEAN_TOKEN`) and, if the API supports a simple bearer-token check, a **verify URL**.

Present the plan as a table: service, access method, key name, permissions, what it allows you to do. Get the user's approval.

## Phase 3: Connect

**Tools.** Install the CLIs the plan needs (`gh`, `git`, `python3`, provider CLIs). Use the OS package manager (Homebrew, winget, apt). Commands that need `sudo` are run by the user.

**Keys.**
1. Add one line per key to `scripts/keys.conf` (variable name, label, optional verify URL). Commit it. It holds names only, never values.
2. Hook the loader into the user's shell (not needed on Windows):
   - macOS/Linux: add these two lines to `~/.zshrc` or `~/.bashrc`, with the real path of this repo:
     ```bash
     export INFRA_HQ_DIR="$HOME/path/to/this/repo"
     source "$INFRA_HQ_DIR/scripts/load-keys.sh"
     ```
3. For each key, give the user step-by-step instructions to create it with exactly the planned permissions (link to the right settings page; the recipe in `services/` has it). Remind them to save it in their password manager.
4. Ask the user to **close the agent**, run `scripts/set-key.sh` (macOS/Linux) or double-click `scripts\set-key.cmd` (Windows), paste each key, and then **open a new terminal** and start the agent again. The script checks each key against its verify URL if one is set.

**SSH.** For each server:
1. Check for an existing key (`ls ~/.ssh/*.pub`). If none, create one: `ssh-keygen -t ed25519 -C "<machine>-infra-hq"`. The user adds a passphrase if they want one.
2. The public key must be added to the server's `authorized_keys`. Do it with the user: through the provider's console, an existing login, or the provider API (some allow adding SSH keys to new servers only).
3. Add a short host alias to `~/.ssh/config` (e.g. `Host vps`), and test with `ssh -o StrictHostKeyChecking=accept-new <alias> hostname`.

**Test everything.** Run every test command from the recipes. Report a clear checklist: what works, what is missing, what lacks a permission. Fix before moving on.

## Phase 4: Discover

Read-only. Build a complete picture from the APIs, not just from what the user remembered:

- **DNS:** list every zone and every record. Note where each record points.
- **Servers:** list them (name, IP, size, location, backups enabled, snapshots). On each server: OS, uptime, disk usage, running containers or services.
- **Platforms and hosting:** list every app or project, its domains, its source repo and branch, and whether it auto-deploys.
- **Databases and storage:** list them, and how each one is backed up.
- **GitHub:** `gh repo list --limit 200`. Match repos to the apps that deploy them.
- **Connect the dots:** domain → DNS record → host or server → app → repo → database. Every live domain should end up somewhere in that chain.

While you look, collect **findings** without fixing anything: DNS records pointing to hosts that no longer exist, apps with no domain, domains with no app, missing backups, untested restores, expiring certificates or domains, things exposed that look like they should be private, unused paid resources. These go in `docs/todo.md`.

## Phase 5: Write it down

Use the skeletons in `templates/`. Write in the language the user chose.

1. `docs/infrastructure.md` from `templates/infrastructure.md`: the map from Phase 4.
2. `docs/machine-setup.md` from `templates/machine-setup.md`: how to connect a *new* computer to everything, specific to this user (keys, SSH hosts, CLIs, tests).
3. `docs/todo.md` from `templates/todo.md`: findings, ordered by importance.
4. Fill in the **This setup** section at the end of `AGENTS.md`: who the user is, language, agents and machines, a "how to reach each service" table, what counts as production, and the user's own rules from Phase 1 (what is precious, what never to do). Keep it short. It is loaded in every session.
5. Replace `README.md` with a short personal README (what this repo is, the main files, "created from [infra-hq](https://github.com/gunnarasgeir/infra-hq)").

Commit and push.

## Phase 6: Every repo knows

So the rules and the map follow the user into their other repos, install a pointer in each agent's **global** instructions. Use `templates/global-pointer.md`, replace the placeholders, and **append** to existing files, never overwrite:

| Agent | Global file | Notes |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` | Supports imports: include `@<repo path>/AGENTS.md` so the full rules load everywhere. Claude may ask the user to approve the import the first time. |
| Codex | `~/.codex/AGENTS.md` (or `$CODEX_HOME/AGENTS.md`) | No imports. The pointer tells Codex to read this repo's `AGENTS.md` before infrastructure work. |
| Gemini CLI / Antigravity | `~/.gemini/GEMINI.md` | Gemini CLI supports `@<path>` imports. |
| Others (Cursor, ...) | See the tool's docs for global or user rules. | Use the plain-text pointer. |

Test: open the agent in another repo and ask "where are my servers documented?". It should point here.

## Phase 7: Hand over

Tell the user, briefly:
- what is connected and what you can now do,
- the most important findings from `docs/todo.md`,
- how to use this from now on: open any agent in this repo (or any repo) and just ask,
- how to connect another computer: open the agent here and say "connect this computer".

Suggest one or two useful first tasks based on the findings (e.g. "You have no off-site backup of X. Want me to set one up?").
