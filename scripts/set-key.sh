#!/usr/bin/env bash
# Stores API keys in the OS key store (see lib-keys.sh). Keys are never shown on screen,
# written to the repo or put on a command line.
#
# Close your AI agent first, then run in a terminal:
#   scripts/set-key.sh
# Open a NEW terminal afterwards so the keys are loaded (via load-keys.sh).
# Which keys exist is defined in scripts/keys.conf.

dir=$(cd "$(dirname "$0")" && pwd)
. "$dir/lib-keys.sh"

grn=$'\e[32m'; red=$'\e[31m'; ylw=$'\e[33m'; cyn=$'\e[36m'; off=$'\e[0m'

vars=(); labels=(); urls=()
while read -r var label url; do
    vars+=("$var"); labels+=("${label:-$var}"); urls+=("$url")
done < <(_ihq_keys "$dir/keys.conf")

if (( ${#vars[@]} == 0 )); then
    echo "${ylw}No keys listed in scripts/keys.conf yet. Ask your agent to add them.${off}"
    exit 0
fi

echo "Key store: $(_ihq_store)"

while true; do
    echo
    echo "${cyn}Which key do you want to set?${off}"
    for i in "${!vars[@]}"; do
        _ihq_get "${vars[$i]}" >/dev/null && state="set" || state="missing"
        printf '  %d. %-14s %-26s (%s)\n' $((i + 1)) "${labels[$i]}" "${vars[$i]}" "$state"
    done
    echo "  0. Quit"

    read -rp "Choose: " choice
    [[ -z "$choice" || "$choice" == 0 ]] && break
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#vars[@]} )); then
        echo "${red}Invalid choice.${off}"; continue
    fi
    i=$((choice - 1))

    read -rsp "Paste the ${labels[$i]} key (it will not be shown): " v; echo
    v=$(printf '%s' "$v" | tr -d '[:space:]')
    if [[ -z "$v" ]]; then echo "${ylw}Nothing entered, skipped.${off}"; continue; fi
    if [[ "$v" == *'"'* || "$v" == *'\'* ]]; then echo "${red}Keys with quotes or backslashes are not supported, skipped.${off}"; v=; continue; fi

    if [[ -n "${urls[$i]}" ]]; then
        code=$(printf '%s\n' "$v" | _ihq_verify "${urls[$i]}")
        if [[ "$code" == 2* ]]; then
            echo "${grn}Verified (HTTP $code).${off}"
        else
            echo "${red}Verification failed (HTTP ${code:-no answer}).${off}"
            read -rp "Save anyway? (y/n) " yn
            [[ "$yn" == y ]] || { v=; continue; }
        fi
    else
        echo "${ylw}No verify URL for this key, saving without a check.${off}"
    fi

    if printf '%s\n' "$v" | _ihq_set "${vars[$i]}"; then
        echo "${grn}Saved: ${vars[$i]}${off}"
    else
        echo "${red}Could not save ${vars[$i]}.${off}"
    fi
    v=
done

echo
echo "${cyn}Keys are only visible in NEW terminals. Open a new one before starting your agent.${off}"
