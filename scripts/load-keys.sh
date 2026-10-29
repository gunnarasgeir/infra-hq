# Loads the keys listed in keys.conf from the key store into environment variables.
# Source it from ~/.zshrc or ~/.bashrc:
#   export INFRA_HQ_DIR="$HOME/path/to/infra-hq"
#   source "$INFRA_HQ_DIR/scripts/load-keys.sh"
# Keys are stored with scripts/set-key.sh.

if [ -z "${INFRA_HQ_DIR:-}" ] || [ ! -f "$INFRA_HQ_DIR/scripts/keys.conf" ]; then
    echo "load-keys.sh: set INFRA_HQ_DIR to the infra-hq repo before sourcing this file" >&2
else
    . "$INFRA_HQ_DIR/scripts/lib-keys.sh"
    while read -r _ihq_var _ihq_rest; do
        _ihq_val=$(_ihq_get "$_ihq_var") && [ -n "$_ihq_val" ] && export "$_ihq_var=$_ihq_val"
    done <<_IHQ_EOF
$(_ihq_keys "$INFRA_HQ_DIR/scripts/keys.conf")
_IHQ_EOF
    unset _ihq_var _ihq_rest _ihq_val
fi
