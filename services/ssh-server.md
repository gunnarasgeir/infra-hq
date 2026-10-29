# Linux server over SSH

Any VPS, dedicated server or home server running Linux. Usually with Docker.

## Access

| | |
|---|---|
| Method | SSH with a key, via a short alias in `~/.ssh/config` |
| Key | An SSH key pair in `~/.ssh` (not an environment variable) |
| Permissions | Root or a sudo user. If the user prefers not to give root, a user in the `docker` group covers most app work. |

```
Host vps
    HostName <ip or hostname>
    User root
    IdentityFile ~/.ssh/id_ed25519
```

## Test

```bash
ssh -o StrictHostKeyChecking=accept-new vps 'hostname; uptime; df -h /; docker ps --format "{{.Names}}\t{{.Status}}" 2>/dev/null'
```

## Common tasks

```bash
ssh vps 'docker ps -a'                                  # containers
ssh vps 'docker logs --tail 100 <container>'
ssh vps 'journalctl -u <service> --since "1 hour ago"'
ssh vps 'df -h; docker system df'                       # disk
ssh vps 'cat /etc/os-release; uname -r'
ssh vps 'ss -tlnp'                                      # listening ports
ssh vps "curl -sI --resolve example.com:443:127.0.0.1 https://example.com/"   # test a site on this server before DNS points here
```

Copying a file to the server: `scp file vps:/path/`, or `ssh vps "cat > /path/file" < file` where SFTP is disabled.

## Before changing things

- Offer a provider snapshot before OS upgrades, Docker changes or disk work.
- Copy config files before editing: `cp file file.YYYY-MM-DD.bak` on the server, and save a copy (secrets stripped) to `history/`.

## Pitfalls

- **Don't lock yourself out.** When changing `sshd_config`, firewall rules (ufw, iptables, provider firewall) or the SSH port, keep the current session open and test a new connection before closing it.
- Provider firewalls and the server's own firewall both apply. Check both when something is unreachable.
- A Docker volume removal (`docker volume rm`, `docker compose down -v`) deletes data permanently. Never do it; move data aside instead or give the user the command.
- Secrets in stdin: never run `ssh host "bash -c \"\$(cat)\""` with a secret in stdin. Copy the script first (`ssh host "cat > /root/x.sh" < x.sh`), then `printf '%s\n' "$SECRET" | ssh host "bash /root/x.sh"`.
