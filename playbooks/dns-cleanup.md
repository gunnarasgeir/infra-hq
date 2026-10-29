# DNS cleanup

Old records pile up: hosts that no longer exist, verification records for services long gone, subdomains nobody remembers. Some are harmless, some are a security risk (a dangling CNAME to a deleted service can be taken over by someone else).

## 1. Collect

Export every record of every zone (see the DNS provider's recipe) and save it to `history/` first. That export is the backup.

## 2. Classify each record

For each record, find out what it is for:

| Check | How |
|---|---|
| Does the target still exist? | A/AAAA: does the IP belong to one of the user's servers? CNAME: does the target resolve (`dig +short <target>`)? |
| Does it answer? | `curl -sI --max-time 10 https://<name>/` |
| Is it in use? | Match against `docs/infrastructure.md`: is there an app, server or service behind it? |
| Is it email? | MX, SPF (`v=spf1`), DKIM (`_domainkey`), DMARC (`_dmarc`), autodiscover: **leave alone** unless the user confirms that mail provider is gone. |
| Is it a verification record? | TXT like `google-site-verification`, `_vercel`, `MS=...`, `facebook-domain-verification`: usually safe to remove only if that service is no longer used. Ask. |

Sort into: **keep** (in use), **remove** (target gone, nothing behind it), **ask** (unclear, email, verification).

## 3. Present, confirm, change

Show the user a table per zone with the proposed action and the reason. Remove only what they approve. Dangling CNAMEs to third-party services are the most urgent.

## 4. Record

Add an entry to `history/README.md` (what was removed and why, link to the backup file), update `docs/infrastructure.md`, commit and push.
