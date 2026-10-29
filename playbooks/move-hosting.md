# Move a site or app to another host

The goal is a move nobody notices: no downtime, no lost data, and an easy way back.

## 1. Inventory the old host

Write down, in `docs/todo.md` or a plan file:
- Domains (apex and `www`), and which one redirects to which.
- Build settings: framework, build command, output, runtime version, Dockerfile if any.
- **Every** environment variable, with its real value (see the pitfalls in the provider's recipe for how to read them). Note which are build-time and which are runtime, and which are secrets.
- Databases, storage buckets, cron jobs, webhooks, redirects and headers configured on the platform (e.g. `vercel.json`, `netlify.toml`, `_redirects`).
- Anything that calls back to the old host (OAuth callback URLs, webhooks from payment providers, CORS allow-lists).

## 2. Build it on the new host

- Create the app from the same repo and branch. Copy env vars. Recreate redirects and headers.
- If data moves too: dump, restore, and **compare** (table list and row counts per table) before going further.
- Deploy and fix build errors.

## 3. Test before DNS changes

Point the request at the new host without touching DNS:

```bash
curl -sI --resolve example.com:443:<new-ip> https://example.com/
```

If the new host is behind a firewall that only admits the CDN, run that `curl` from the server itself with `127.0.0.1`. Check the home page, a few deep links, forms, login, images, and redirects (`www` ↔ apex, `http` → `https`).

## 4. Switch

1. Back up the current DNS records to `history/`.
2. Lower the TTL a while before if the records are not proxied.
3. **Confirm with the user**, then change the records.
4. Verify from outside: `curl -sI https://example.com/`, check the certificate, check `www` and the apex.

## 5. Clean up later

- Keep the old host running for a few days. Then, with the user's confirmation, remove the domain from the old project and pause or delete it.
- Update `docs/infrastructure.md` and `history/README.md`, and commit.
- Update callback URLs and webhooks if they pointed to the old host's own URL.
