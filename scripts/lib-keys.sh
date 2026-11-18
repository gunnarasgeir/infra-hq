# Shared helpers for set-key.sh, check-keys.sh and load-keys.sh. Works in bash and zsh.
#
# Where keys are stored (override with INFRA_HQ_KEYSTORE=keychain|secret-tool|file|1password):
#   macOS:  Keychain, service "infra-hq"
#   Linux:  secret-tool (GNOME Keyring / KWallet) if installed, otherwise
#           ~/.config/infra-hq/keys.env (readable only by the user)
#   1password (opt-in, needs the `op` CLI): one "API Credential" item per key, titled with
#           the variable name, field "credential", in vault $INFRA_HQ_OP_VAULT (default infra-hq).
#           On a personal machine set INFRA_HQ_OP_ACCOUNT (shorthand or sign-in address) so
#           keys never land in the wrong account, e.g. a work account. On a headless machine
#           set OP_SERVICE_ACCOUNT_TOKEN instead (a service account scoped to that vault).
# Values never go on a command line, so they do not show up in the process list.

_ihq_store() {
    if [ -n "${INFRA_HQ_KEYSTORE:-}" ]; then echo "$INFRA_HQ_KEYSTORE"
    elif [ "$(uname -s)" = Darwin ]; then echo keychain
    elif command -v secret-tool >/dev/null 2>&1; then echo secret-tool
    else echo file
    fi
}

_ihq_file() { echo "${XDG_CONFIG_HOME:-$HOME/.config}/infra-hq/keys.env"; }

# Fails with a message when no 1Password account is configured. Never guesses one.
_ihq_op_ok() {
    [ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}${INFRA_HQ_OP_ACCOUNT:-}" ] && return 0
    echo "lib-keys: set INFRA_HQ_OP_ACCOUNT (or OP_SERVICE_ACCOUNT_TOKEN) to use 1password" >&2
    return 1
}

# Runs op against the configured account
_ihq_op() {
    if [ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]; then op "$@"
    else op --account "$INFRA_HQ_OP_ACCOUNT" "$@"
    fi
}

_ihq_op_vault() { echo "${INFRA_HQ_OP_VAULT:-infra-hq}"; }

# Prints the stored value of key $1, fails if it is not stored
_ihq_get() {
    case "$(_ihq_store)" in
        keychain)    security find-generic-password -s infra-hq -a "$1" -w 2>/dev/null ;;
        secret-tool) secret-tool lookup service infra-hq account "$1" 2>/dev/null ;;
        1password)   _ihq_op_ok && _ihq_op read --no-newline "op://$(_ihq_op_vault)/$1/credential" 2>/dev/null ;;
        *)         [ -f "$(_ihq_file)" ] && grep -q "^$1=" "$(_ihq_file)" && sed -n "s/^$1=//p" "$(_ihq_file)" | head -n 1 ;;
    esac
}

# Stores key $1 with the value read from stdin
_ihq_set() {
    local v f
    IFS= read -r v
    case "$(_ihq_store)" in
        keychain)
            # security -i reads the command from stdin, so the value stays off the process list
            printf 'add-generic-password -U -s infra-hq -a %s -l "infra-hq %s" -w "%s"\n' "$1" "$1" "$v" | security -i >/dev/null ;;
        secret-tool)
            printf '%s' "$v" | secret-tool store --label="infra-hq $1" service infra-hq account "$1" ;;
        1password)
            # The value travels as a JSON item template on stdin, never as an argument
            local json vault
            _ihq_op_ok || return 1
            vault=$(_ihq_op_vault)
            json=$(printf '%s' "$v" | python3 -c 'import json,sys
print(json.dumps({"title": sys.argv[1], "category": "API_CREDENTIAL",
  "fields": [{"id": "credential", "label": "credential", "type": "CONCEALED", "value": sys.stdin.read()}]}))' "$1") || return 1
            if _ihq_op item get "$1" --vault "$vault" >/dev/null 2>&1; then
                printf '%s' "$json" | _ihq_op item edit "$1" --vault "$vault" >/dev/null
            else
                printf '%s' "$json" | _ihq_op item create --vault "$vault" - >/dev/null
            fi
            json= ;;
        *)
            f=$(_ihq_file)
            mkdir -p "$(dirname "$f")" && chmod 700 "$(dirname "$f")"
            touch "$f" && chmod 600 "$f"
            { grep -v "^$1=" "$f"; printf '%s=%s\n' "$1" "$v"; } > "$f.tmp" && mv "$f.tmp" "$f" && chmod 600 "$f" ;;
    esac
}

# Prints the HTTP status of verify URL $1 called with the key from stdin as a bearer token
_ihq_verify() {
    local v
    IFS= read -r v
    printf 'Authorization: Bearer %s\n' "$v" | curl -s -o /dev/null -w '%{http_code}' --max-time 15 -H @- "$1"
}

# Prints "VAR LABEL URL" for each key in keys.conf
_ihq_keys() {
    grep -v '^[[:space:]]*#' "$1" | grep -v '^[[:space:]]*$'
}
