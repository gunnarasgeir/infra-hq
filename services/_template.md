# <Service name>

One or two sentences: what this service is and what an agent typically does with it.

## Access

| | |
|---|---|
| Method | Official CLI / REST API / SSH / MCP |
| Key | `ENV_VARIABLE_NAME` |
| Create it at | Exact settings page (URL or menu path) |
| Permissions | What typical tasks need (with write access), and what to leave out (billing, account deletion, user/token management, root). Say which ones are read-only and which allow changes. |
| Verify URL | An endpoint that returns 2xx for a valid bearer token, for `scripts/keys.conf` (or "none") |
| API docs | Link |

## Test

```bash
# Read-only command that proves the connection works and shows something recognizable
```

## Common tasks

Short snippets for the things users usually ask for (list, deploy, change a setting, back up).

## Before changing things

What to back up to `history/` first, and how to restore it.

## Pitfalls

- Things that surprised us. Responses that contain secrets. Endpoints that replace instead of merge. Rate limits.
