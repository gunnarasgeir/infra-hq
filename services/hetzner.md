# Hetzner Cloud

Cloud servers, snapshots, automatic backups, firewalls, volumes. (Hetzner dedicated servers use the separate Robot API.)

## Access

| | |
|---|---|
| Method | REST API with `curl` (optionally the `hcloud` CLI), plus SSH to the servers (see `ssh-server.md`) |
| Key | `HCLOUD_TOKEN` |
| Create it at | console.hetzner.cloud → the project → Security → API tokens. Read & Write (or Read only for monitoring). |
| Verify URL | `https://api.hetzner.cloud/v1/servers` |
| API docs | https://docs.hetzner.cloud/ |

Tokens are **per project**. A user with several projects needs a token for each, with separate variable names.

## Test

```bash
curl -s -H "Authorization: Bearer $HCLOUD_TOKEN" https://api.hetzner.cloud/v1/servers | python3 -c "import sys,json;[print(s['id'],s['name'],s['status'],s['server_type']['name'],s['public_net']['ipv4']['ip'],'backups' if s['backup_window'] else 'NO backups') for s in json.load(sys.stdin)['servers']]"
```

## Common tasks

```bash
H="Authorization: Bearer $HCLOUD_TOKEN"; API=https://api.hetzner.cloud/v1
curl -s -X POST -H "$H" -H "Content-Type: application/json" $API/servers/<id>/actions/create_image -d '{"type":"snapshot","description":"Before <change>"}'   # snapshot
curl -s -H "$H" "$API/images?type=snapshot"                 # list snapshots
curl -s -H "$H" $API/firewalls                              # firewalls and rules
curl -s -X POST -H "$H" $API/servers/<id>/actions/enable_backup   # automatic daily backups (costs extra)
```

## Before changing things

- Offer a snapshot before big server changes. Snapshots cost a little per GB per month; tell the user and offer to delete old ones later.
- Save firewall rules to `history/` before changing them.

## Pitfalls

- `POST firewalls/<id>/actions/set_rules` **replaces all rules**. Always send the full list (existing rules plus the new one).
- Automatic backups are tied to the server: deleting the server deletes its backups. Convert one to a snapshot first if the server is going away.
- Enable delete/rebuild protection on production servers (`actions/change_protection`).
- Rebooting or resizing a server takes everything on it offline. Confirm first.
