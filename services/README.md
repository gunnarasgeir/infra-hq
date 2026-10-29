# Service recipes

One file per service type. Each recipe tells an agent how to connect to that kind of service, which key permissions to ask for, how to test the connection, and which pitfalls to avoid.

Recipes are **generic**: no personal domains, IDs, IPs or account names. Those go in `docs/infrastructure.md`.

**A missing recipe is not a blocker.** If the user runs something not listed here, research the provider's official API and CLI docs and write a new recipe from [`_template.md`](_template.md). Keep it short and practical. Add pitfalls whenever you hit one.

| Recipe | Covers |
|---|---|
| [`github.md`](github.md) | Repos, Actions secrets, deploy keys |
| [`ssh-server.md`](ssh-server.md) | Any Linux server or VPS reached over SSH, Docker on it |
| [`cloudflare.md`](cloudflare.md) | DNS, proxy, SSL, redirects, Zero Trust Access, Tunnels |
| [`hetzner.md`](hetzner.md) | Hetzner Cloud servers, snapshots, backups, firewalls |
| [`coolify.md`](coolify.md) | Self-hosted PaaS on your own server |
| [`vercel.md`](vercel.md) | Projects, deployments, env vars, domains |
| [`supabase.md`](supabase.md) | Supabase Cloud projects |
| [`neon.md`](neon.md) | Serverless Postgres with branches |
| [`convex.md`](convex.md) | Convex backend projects |
| [`synology.md`](synology.md) | Synology NAS (DSM) as a home server |
