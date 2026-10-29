# Supabase

Hosted Postgres with auth, storage, edge functions and realtime.

## Access

| | |
|---|---|
| Method | `supabase` CLI and the Management API, optionally the Supabase MCP server |
| Key | `SUPABASE_ACCESS_TOKEN` (also picked up by the CLI) |
| Create it at | supabase.com/dashboard/account/tokens |
| Verify URL | `https://api.supabase.com/v1/projects` |
| API docs | https://supabase.com/docs/reference/api |

The token covers every organization the user belongs to. Projects in a **different Supabase account** need a separate token (e.g. `SUPABASE_ACCESS_TOKEN_2`) or a separate login.

## Test

```bash
supabase projects list
curl -s -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" https://api.supabase.com/v1/projects | python3 -c "import sys,json;[print(p['id'],p['name'],p['region'],p['status']) for p in json.load(sys.stdin)]"
```

## Common tasks

```bash
supabase link --project-ref <ref>                 # inside an app repo
supabase db dump --linked -f backup.sql           # schema; add --data-only for data
supabase migration list --linked
supabase functions list --project-ref <ref>
```

## Before changing things

Take a dump before migrations or destructive SQL. Prefer testing on a branch or a separate project first.

## Pitfalls

- Free-plan projects are paused after a period of inactivity, and the Free plan limits how many active projects an organization can have.
- Check which backups the plan includes and whether they can be downloaded. On Free, set up your own `pg_dump` schedule if the data matters.
- The `service_role` key bypasses row-level security. Never expose it to a frontend, never print it.
