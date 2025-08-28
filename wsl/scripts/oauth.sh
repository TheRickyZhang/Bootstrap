#!/usr/bin/env bash
set -euo pipefail
EMAIL="${EMAIL:-rickyzhang196@outlook.com}"
ACC="${ACC:-outlook}"
TOKEN="${TOKEN:-$HOME/.config/mutt/$ACC.token}"

# Use same helper discovery as before
if [ -x /usr/share/neomutt/oauth2/mutt_oauth2.py ]; then
  OAUTH=/usr/share/neomutt/oauth2/mutt_oauth2.py
else
  OAUTH="$HOME/.local/bin/mutt_oauth2.py"
fi

mkdir -p "$(dirname "$TOKEN")"
# This launches a device-code prompt; follow instructions once
"$OAUTH" "$TOKEN" --authorize --verbose
echo "Token stored at $TOKEN"
