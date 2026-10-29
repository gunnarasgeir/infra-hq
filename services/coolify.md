# Coolify

Self-hosted PaaS (like Heroku/Vercel on your own server): apps from GitHub, databases, scheduled backups, Traefik proxy with automatic certificates.

## Access

| | |
|---|---|
| Method | Coolify REST API, plus SSH to the server for logs and Docker |
| Key | `COOLIFY_API_TOKEN` |
| Create it at | Coolify dashboard → Keys & Tokens → API tokens. Permissions: `read`, `write`, `deploy`. Avoid `root` and `read:sensitive`. |
| Verify URL | `https://<coolify-host>/api/v1/version`, unless the dashboard is behind a login gateway (then none, test via SSH) |
| API docs | https://coolify.io/docs/api-reference |

The API must be enabled: Settings → Advanced → API Access.

**If the dashboard is behind a login gateway** (e.g. Cloudflare Access), call the API through SSH on the server instead. Save this as `scripts/coolify.sh` and set the SSH alias:

```bash
#!/usr/bin/env bash
# Calls the Coolify API through SSH on localhost:8000. The token goes over stdin, so it never shows in process lists.
# Usage: scripts/coolify.sh GET applications
#        scripts/coolify.sh PATCH "applications/<uuid>" '{"name":"new-name"}'   # JSON on one line
set -euo pipefail
host=${COOLIFY_SSH_HOST:-vps}
method=${1:?usage: coolify.sh METHOD PATH [JSON]}; path=${2:?usage: coolify.sh METHOD PATH [JSON]}; body=${3:-}
: "${COOLIFY_API_TOKEN:?COOLIFY_API_TOKEN is not set}"
printf '%s\n%s\n' "$COOLIFY_API_TOKEN" "$body" | ssh "$host" bash -c "'
read -r T; read -r B
args=()
[ -n \"\$B\" ] && args=(-H \"Content-Type: application/json\" --data \"\$B\")
curl -sS -X $method -H \"Authorization: Bearer \$T\" -H \"Accept: application/json\" \"\${args[@]}\" \"http://localhost:8000/api/v1/${path#/}\"
'"
echo
```

## Test

```bash
scripts/coolify.sh GET version
scripts/coolify.sh GET applications | python3 -c "import sys,json;[print(a['uuid'],a['name'],a['status'],a.get('fqdn'),a.get('git_repository'),a.get('git_branch')) for a in json.load(sys.stdin)]"
```

## Common tasks

```bash
scripts/coolify.sh GET servers
scripts/coolify.sh GET projects
scripts/coolify.sh GET databases
scripts/coolify.sh GET "applications/<uuid>/envs"
scripts/coolify.sh GET "deploy?uuid=<uuid>"              # deploy
scripts/coolify.sh POST "applications/<uuid>/restart"
ssh vps 'docker logs --tail 100 $(docker ps -qf name=<uuid>)'
```

**Moving a site here from another host:** create the app (or do it in the dashboard), copy env vars, deploy, then test before DNS changes: `ssh vps "curl -sI --resolve example.com:443:127.0.0.1 https://example.com/"`. See `playbooks/move-hosting.md`.

## Pitfalls

- **Creating resources returns secrets.** `POST databases/*` answers with `internal_db_url` including the password. Filter responses (`| python3 -c "...print(d['uuid'])"`). Plain `GET` hides them unless the token has `read:sensitive`.
- **Proxy labels are not regenerated** when domains or the www/non-www redirect are changed via the API after an app exists, so e.g. the redirect middleware is missing. Fix: "Reset to Coolify Default Labels" in the app's settings, then redeploy.
- **Build-time secrets end up in image history** as `ARG` unless "Docker Build Secrets" is enabled on the app (`use_build_secrets`). Enable it for apps that need secrets at build time.
- Traefik's certificates and config live in `/data/coolify/proxy/`. Back up `docker-compose.yml` there (secrets stripped) before editing it.
- Scheduled database backups can go to S3-compatible storage (R2, B2, S3). Without that, backups only live on the same server.
- Coolify updates itself if auto-update is on. Offer a server snapshot before manual major upgrades.
