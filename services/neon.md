# Neon

Serverless Postgres with instant branches (copy-on-write copies of a database).

## Access

| | |
|---|---|
| Method | REST API with `curl`, `neonctl` CLI, optionally the Neon MCP server |
| Key | `NEON_API_KEY` |
| Create it at | console.neon.tech → Account settings → API keys (or an organization API key) |
| Verify URL | `https://console.neon.tech/api/v2/users/me` |
| API docs | https://api-docs.neon.tech/ |

## Test

```bash
curl -s -H "Authorization: Bearer $NEON_API_KEY" https://console.neon.tech/api/v2/projects | python3 -c "import sys,json;[print(p['id'],p['name'],p['region_id']) for p in json.load(sys.stdin)['projects']]"
```

## Common tasks

```bash
H="Authorization: Bearer $NEON_API_KEY"; API=https://console.neon.tech/api/v2
curl -s -H "$H" $API/projects/<project_id>/branches
curl -s -X POST -H "$H" -H "Content-Type: application/json" $API/projects/<project_id>/branches -d '{"branch":{"name":"test-<change>"},"endpoints":[{"type":"read_write"}]}'
```

## Before changing things

**Test on a branch first.** Create a branch from production, apply the migration or SQL there, verify, then apply to production with the user's confirmation.

## Pitfalls

- Creating branches and endpoints returns connection strings with passwords. Filter the response.
- Point-in-time restore depends on the plan's history retention window.
- Organization projects may need `org_id` in API calls.
