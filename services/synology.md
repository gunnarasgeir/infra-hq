# Synology NAS

A Synology NAS (DSM) used as a home server: file storage, Docker apps via Container Manager, scheduled tasks, often published to the internet through a tunnel.

## Access

| | |
|---|---|
| Method | SSH with a key (see `ssh-server.md`) |
| Key | SSH key pair in `~/.ssh` |
| Setup | DSM → Control Panel → Terminal & SNMP → Enable SSH. Log in with an **administrator** account. Enable User Home (Control Panel → User & Group → Advanced) so `~/.ssh/authorized_keys` works. |

Home directories need tight permissions for key login: `chmod 755 ~; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys`.

## Docker without a password

`sudo` on DSM asks for the password, which the agent must never handle. Let the user add a narrow sudoers rule (they run this themselves):

```bash
echo '<user> ALL=(root) NOPASSWD: /usr/local/bin/docker' | sudo tee /etc/sudoers.d/<user>-docker && sudo chmod 440 /etc/sudoers.d/<user>-docker
```

Then: `ssh nas 'sudo -n /usr/local/bin/docker ps'`. A DSM update can remove the rule; recreate it if `sudo -n` starts failing.

## Test

```bash
ssh nas 'hostname; cat /etc.defaults/VERSION | grep -E "productversion|buildnumber"; df -h | grep volume'
ssh nas 'sudo -n /usr/local/bin/docker ps --format "{{.Names}}\t{{.Status}}"'
```

## Common tasks

```bash
ssh nas 'ls /volume1/docker /volume2/docker 2>/dev/null'   # where Container Manager projects usually live
ssh nas 'sudo -n /usr/local/bin/docker logs --tail 100 <container>'
ssh nas "cat > /path/file" < file                          # copy a file (scp often fails, see below)
```

Recurring jobs: use DSM → Control Panel → **Task Scheduler** (user-defined script), not crontab, which DSM can overwrite.

## Pitfalls

- **`scp` fails with "Connection closed"** when SFTP is disabled in DSM. Use `ssh nas "cat > path" < file`.
- The NAS is usually only reachable on the home network. If `ssh` times out, the user is probably away. Say so and wait; don't set up remote access unless the user asks for it.
- Volumes differ (RAID of large disks vs. a single SSD). Record which volume is for what in `docs/infrastructure.md` and ask before placing new apps.
- Container Manager projects are docker compose projects. Editing the compose file outside DSM works, but DSM's UI may show stale state until the project is rebuilt there.
- A NAS is often the only copy of family photos or archives. Read freely; ask before changing anything, and check that an off-site backup exists.
