# GitHub

The one service every infra-hq setup has. Holds this repo and usually the source of every site and app.

## Access

| | |
|---|---|
| Method | `gh` CLI |
| Key | None to store. The user runs `gh auth login` (opens a browser). |
| Permissions | Default `gh` scopes plus `workflow` if the agent should edit GitHub Actions: `gh auth refresh -s workflow` |
| API docs | https://cli.github.com/manual/ |

## Test

```bash
gh auth status
gh repo list --limit 200 --json nameWithOwner,visibility,pushedAt,isArchived
```

## Common tasks

```bash
gh repo view <owner>/<repo> --json visibility,defaultBranchRef
gh api repos/<owner>/<repo>/hooks                  # webhooks (e.g. deploys triggered by pushes)
gh api repos/<owner>/<repo>/keys                   # deploy keys
gh secret list -R <owner>/<repo>
gh secret set NAME -R <owner>/<repo> < file        # value from a file or stdin, never on the command line
gh run list -R <owner>/<repo> --limit 5            # recent Actions runs
```

Mapping repos to deployments: most hosting platforms record the source repo and branch of each app. Combine their API output with `gh repo list` to fill the "Source repo" column in `docs/infrastructure.md`.

## Pitfalls

- `gh auth login` is interactive. The user runs it (in Claude Code: `! gh auth login`).
- Secret values cannot be read back from GitHub, only overwritten. Make sure the user has them in their password manager.
- Archived repos still show up in `gh repo list`. Filter with `isArchived`.
