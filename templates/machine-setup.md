# Connecting a new computer

> **For the agent.** The user asked you to connect this computer to their services. Go step by step and confirm each step with the tests at the end.
> - **Never ask for keys in the chat.** The user sets them with `scripts/set-key.*` with the agent closed.
> - If this repo already exists on the machine: `git pull` first.

<!-- Skeleton used during onboarding. Make every step specific to this user: their keys, their servers, their tools. -->

## Keys

Where the user keeps them (password manager entry names) and what each one is for:

| Password manager entry | Environment variable | Permissions |
|---|---|---|
| | | |

## 1. Tools

Install on macOS: `brew install gh git python ...`
Install on Windows: `winget install GitHub.cli Git.Git Python.Python.3.12 ...`
Install on Linux: `sudo apt install gh git python3 ...` (the user runs `sudo`)

## 2. GitHub and this repo

The user runs `gh auth login` themselves (it opens a browser). Then clone this repo.

## 3. Keys

- macOS/Linux: add to `~/.zshrc` (or `~/.bashrc`), with the real path:
  ```bash
  export INFRA_HQ_DIR="$HOME/path/to/this/repo"
  source "$INFRA_HQ_DIR/scripts/load-keys.sh"
  ```
- With the agent closed, the user runs `scripts/set-key.sh` (or `scripts\set-key.cmd` on Windows) and pastes each key from the password manager.
- Open a new terminal before starting the agent again.

## 4. SSH

Which key, and the `~/.ssh/config` entries:

```
Host <alias>
    HostName <ip>
    User <user>
    IdentityFile ~/.ssh/id_ed25519
```

## 5. Global agent instructions

Install the pointer from `templates/global-pointer.md` for each agent the user uses on this machine (see `docs/onboarding.md`, Phase 6).

## 6. Optional: MCP servers

Per agent, if the user wants them.

## Tests

Run from the repo root. Never print keys.

```bash
scripts/check-keys.sh          # which keys are set (names only) and whether they verify
gh auth status
ssh <alias> hostname
# one read-only test per service, from services/<name>.md
```

## Troubleshooting

| Problem | Fix |
|---|---|
| Keys not visible to the agent | The agent was started from an old terminal. Open a new one and start it again. |
| | |
