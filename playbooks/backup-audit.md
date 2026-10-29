# Backup audit

Answer one question for everything the user cares about: **if this disappeared tonight, how would we get it back, and how much would be lost?**

## 1. List what holds data

From `docs/infrastructure.md`: databases, servers with volumes, object storage, NAS shares, SaaS with content (CMS, file storage). Ask the user what matters most. Code in GitHub is already backed up; data usually is not.

## 2. For each, find out

| Question | Look for |
|---|---|
| Is it backed up at all? | Provider backups, scheduled dumps, snapshot schedules, NAS backup tasks |
| Where do backups go? | Same server? Same provider? Off-site? |
| How often, and how many are kept? | Schedule and retention |
| Does it survive the account or server being deleted? | Provider backups are often tied to the resource |
| Has a restore ever been tested? | If not, it is a hope, not a backup |
| Do the last runs succeed? | Logs, status in the provider's dashboard or API |

The rule of thumb is **3-2-1**: three copies, on two kinds of storage, one off-site.

## 3. Report

A table: data, backup method, location, frequency, last success, restore tested, verdict (good / weak / none). Put gaps in `docs/todo.md` under **Important**, most valuable data first.

## 4. Offer fixes

Typical fixes: scheduled database dumps to S3-compatible storage (R2, B2, S3), enabling provider backups, a NAS cloud backup task, and **a test restore** into a temporary database or folder, compared against the original.
