# Vercel

Hosting for frontends and serverless apps: projects, deployments, env vars, domains.

## Access

| | |
|---|---|
| Method | REST API with `curl`, `vercel` CLI with `--token`, optionally the Vercel MCP server |
| Key | `VERCEL_TOKEN` |
| Create it at | vercel.com/account/tokens. Scope it to the team that owns the projects. |
| Verify URL | `https://api.vercel.com/v2/user` |
| API docs | https://vercel.com/docs/rest-api |

Note the **team ID** (`team_...`) in `docs/infrastructure.md`. Add `?teamId=<id>` to API calls for team projects.

## Test

```bash
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" https://api.vercel.com/v2/user | python3 -c "import sys,json;print(json.load(sys.stdin)['user']['username'])"
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" "https://api.vercel.com/v9/projects?teamId=<team_id>&limit=100" | python3 -c "import sys,json;[print(p['name'],(p.get('link') or {}).get('repo')) for p in json.load(sys.stdin)['projects']]"
```

## Common tasks

```bash
vercel project ls --token "$VERCEL_TOKEN" --scope <team>
vercel ls <project> --token "$VERCEL_TOKEN" --scope <team>               # deployments
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" "https://api.vercel.com/v9/projects/<project>/domains?teamId=<team_id>"
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" "https://api.vercel.com/v10/projects/<project>/env?teamId=<team_id>"   # list env vars (values encrypted)
```

## Before changing things

Save the project's env var names and domain list to `history/` before moving or deleting a project. Production promotions, rollbacks, pausing and production env var changes need the user's confirmation.

## Pitfalls

- **Listing env vars does not return readable values.** `?decrypt=true` on the list endpoint still returns encrypted values (`decrypted: false`). Fetch each variable separately with `GET /v1/projects/<project>/env/<id>` and check it is decrypted before copying it elsewhere. "Sensitive" variables can never be read back.
- If DNS for the user's domains is managed elsewhere (e.g. Cloudflare), **don't** use Vercel's DNS endpoints. Add the domain to the project in Vercel and create the record at the real DNS provider.
- Never buy domains through the API unless the user explicitly asks.
- Moving a site off Vercel: remove the domain from the Vercel project only **after** DNS points to the new host and it is verified, or Vercel may stop serving it too early.
