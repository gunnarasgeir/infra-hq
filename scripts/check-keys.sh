#!/usr/bin/env bash
# Shows which keys from keys.conf are available and whether they verify. Never prints values.
#   scripts/check-keys.sh

dir=$(cd "$(dirname "$0")" && pwd)
. "$dir/lib-keys.sh"

status=0
while read -r var label url; do
    v=${!var:-}
    where="env"
    if [[ -z "$v" ]]; then
        v=$(_ihq_get "$var") && where="store only, open a new terminal" || where=""
    fi
    if [[ -z "$v" ]]; then
        printf '%-26s MISSING\n' "$var"; status=1; continue
    fi
    if [[ -n "$url" ]]; then
        code=$(printf '%s\n' "$v" | _ihq_verify "$url")
        [[ "$code" == 2* ]] && result="OK (HTTP $code)" || { result="FAILED (HTTP ${code:-no answer})"; status=1; }
    else
        result="set (no verify URL)"
    fi
    printf '%-26s %s [%s]\n' "$var" "$result" "$where"
done < <(_ihq_keys "$dir/keys.conf")
v=
exit $status
