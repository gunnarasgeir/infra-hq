# Convex

Backend platform (database, server functions, scheduling) used from app code.

## Access

| | |
|---|---|
| Method | `npx convex` CLI, Management API with `curl`, optionally the Convex MCP server |
| Key | `CONVEX_TEAM_TOKEN` (team access token) |
| Create it at | dashboard.convex.dev → Team Settings → Access Tokens. The team ID is shown there too. |
| Verify URL | `https://api.convex.dev/v1/token_details` |
| API docs | https://docs.convex.dev/management-api |

The CLI uses its own login (`npx convex login`, stored in `~/.convex/`). The user runs it, since it opens a browser.

## Test

```bash
curl -s -H "Authorization: Bearer $CONVEX_TEAM_TOKEN" https://api.convex.dev/v1/token_details | python3 -c "import sys,json;print(json.load(sys.stdin)['teamId'])"
curl -s -H "Authorization: Bearer $CONVEX_TEAM_TOKEN" https://api.convex.dev/v1/teams/<team_id>/projects | python3 -c "import sys,json;[print(p['name'],p.get('prodDeploymentName')) for p in json.load(sys.stdin)['items']]"
```

## Common tasks

```bash
npx convex data <table> --deployment <deployment-name>   # read a table, works from any directory
npx convex export --path backup.zip --deployment <name>  # full export
```

## Pitfalls

- Deleting a project, deployment or deploy key is irreversible. Confirm first.
- Deploy keys give full write access to a deployment. Treat them like passwords.
