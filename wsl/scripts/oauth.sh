#!/usr/bin/env bash
set -euo pipefail

EMAIL="${EMAIL:-rickyzhang196@outlook.com}"
ACC="${ACC:-outlook}"
TOKEN="${TOKEN:-$HOME/.config/mutt/$ACC.token}"
PROVIDER="${PROVIDER:-microsoft}"
FLOW="${FLOW:-devicecode}" # or localhostauthcode/authcode
CLIENT_ID="${CLIENT_ID:-}" # optional: set to force a specific client id

# find helper
if [ -x /usr/share/neomutt/oauth2/mutt_oauth2.py ]; then
  OAUTH=/usr/share/neomutt/oauth2/mutt_oauth2.py
else
  OAUTH="$HOME/.local/bin/mutt_oauth2.py"
fi

mkdir -p "$(dirname "$TOKEN")"

# WSL: let helpers open Windows browser if needed (harmless for devicecode)
if grep -qi microsoft /proc/version 2>/dev/null; then
  if [ -z "${BROWSER+x}" ]; then
    if command -v wslview >/dev/null; then
      export BROWSER=wslview
    elif [ -x /mnt/c/Windows/explorer.exe ]; then
      export BROWSER=/mnt/c/Windows/explorer.exe
    fi
  fi
fi

# Prefer explicit flags if available; otherwise feed prompts
HELP="$("$OAUTH" --help 2>&1 || true)"
if printf '%s' "$HELP" | grep -q -- '--flow'; then
  args=("$TOKEN" --authorize --provider "$PROVIDER" --flow "$FLOW" --verbose)
  if printf '%s' "$HELP" | grep -q -- '--user'; then
    args+=(--user "$EMAIL")
  else
    args+=(--email "$EMAIL")
  fi
  [ -n "$CLIENT_ID" ] && args+=(--client-id "$CLIENT_ID")
  "$OAUTH" "${args[@]}"
else
  {
    echo "$PROVIDER"
    echo "$FLOW"
    echo "$EMAIL"
  } | "$OAUTH" "$TOKEN" --authorize --verbose
fi

echo "Token stored at $TOKEN"
