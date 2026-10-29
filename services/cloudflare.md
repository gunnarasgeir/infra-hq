# Cloudflare

DNS, proxy and CDN, SSL, redirects, Zero Trust Access (login in front of sites) and Tunnels (publish a home server without opening ports).

## Access

| | |
|---|---|
| Method | REST API with `curl` (optionally `wrangler` for Workers/Pages) |
| Key | `CLOUDFLARE_API_TOKEN` |
| Create it at | dash.cloudflare.com → My Profile → API Tokens → Create Token → Custom token |
| Verify URL | `https://api.cloudflare.com/client/v4/user/tokens/verify` |
| API docs | https://developers.cloudflare.com/api/ |

**Permissions** (pick what the user wants managed):
- Zone: Zone (Read), DNS (Edit). Add Zone Settings (Edit), SSL and Certificates (Edit), Single Redirect (Edit), Cache Purge (Purge), Firewall Services (Edit) for more.
- Account: Account Settings (Read). For Access: Access: Apps and Policies (Edit) and Access: Organizations, Identity Providers, and Groups (Edit). For tunnels: Cloudflare Tunnel (Edit).
- Zone Resources: All zones (or specific ones). Account Resources: the user's account.

Also note the **Account ID** (dashboard → any domain → right column) in `docs/infrastructure.md`.

## Test

```bash
H="Authorization: Bearer $CLOUDFLARE_API_TOKEN"; API=https://api.cloudflare.com/client/v4
curl -s -H "$H" $API/user/tokens/verify | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['success'],d['result']['status'])"
curl -s -H "$H" "$API/zones?per_page=50" | python3 -c "import sys,json;[print(z['id'],z['name'],z['status']) for z in json.load(sys.stdin)['result']]"
```

## Common tasks

```bash
# All DNS records in a zone
curl -s -H "$H" "$API/zones/<zone_id>/dns_records?per_page=500" | python3 -c "import sys,json;[print(r['id'],r['type'],r['name'],r['content'],'proxied' if r.get('proxied') else 'dns-only') for r in json.load(sys.stdin)['result']]"

# Create, change, delete a record (back up first, see below)
curl -s -X POST  -H "$H" -H "Content-Type: application/json" $API/zones/<zone_id>/dns_records -d '{"type":"A","name":"sub.example.com","content":"203.0.113.10","proxied":true,"ttl":1}'
curl -s -X PATCH -H "$H" -H "Content-Type: application/json" $API/zones/<zone_id>/dns_records/<record_id> -d '{"content":"203.0.113.20"}'
curl -s -X DELETE -H "$H" $API/zones/<zone_id>/dns_records/<record_id>

# SSL mode of a zone (off, flexible, full, strict)
curl -s -H "$H" $API/zones/<zone_id>/settings/ssl

# Access apps (logins in front of sites)
curl -s -H "$H" $API/accounts/<account_id>/access/apps
```

**Protecting a site with a login (Access):** create a self-hosted Access app for the hostname with a policy allowing specific emails, using an identity provider (Google, GitHub, one-time PIN). Doing it once in the dashboard and then copying the pattern via the API works well.

## Before changing things

Save the zone's records before changing or deleting any: `curl ... /dns_records?per_page=500 > history/YYYY-MM-DD-<zone>-dns.json`. To restore, recreate records from that file. Do the same for Access apps and policies.

## Pitfalls

- **Email records (MX, SPF/TXT, DKIM, DMARC) are easy to break and hard to notice.** Never touch them as part of a cleanup without explicit confirmation.
- Hostnames behind Access return an HTML login page to scripts, not JSON. Call such services another way (e.g. via SSH on the server).
- Proxied records (orange cloud) hide the origin IP and only pass standard HTTP(S) ports. Non-standard ports or non-HTTP traffic need "DNS only".
- SSL "Flexible" with an origin that redirects to HTTPS causes redirect loops. Use "Full" or "Full (strict)" when the origin has a certificate.
- A tunnel hostname is a CNAME to `<tunnel-id>.cfargotunnel.com`. Deleting the record does not delete the tunnel route, and vice versa.
- Origins behind a server firewall that only admits Cloudflare's IP ranges cannot be tested directly from outside. Test from the server itself with `curl --resolve`.
