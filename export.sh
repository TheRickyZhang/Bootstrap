#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
CONFIG_COPY="$REPO/configCopy"
MAP="$REPO/deps/configmap.txt"
EXCLUDE="$REPO/.gitignore"

[ -f "$MAP" ] || { echo "missing $MAP"; exit 1; }
mkdir -p "$CONFIG_COPY"

# bulk export ~/.config -> $CONFIG_COPY/.config
rsync -a --delete --itemize-changes \
  --filter=":- $EXCLUDE" \
  "$HOME/.config/" "$CONFIG_COPY/"

copy_one() {
  raw="$1"
  dst="$CONFIG_COPY/$2"

  case "$raw" in
    "~")   src="$HOME" ;;
    ~/*)   src="$HOME/${raw#~/}" ;;
    /*)    src="$raw" ;;            # absolute system path like /etc/...
    *)     src="$HOME/$raw" ;;      # default: relative to $HOME
  esac

  [ -e "$src" ] || { echo "missing $src"; return 1; }
  mkdir -p "$(dirname "$dst")"
  if command -v rsync >/dev/null; then
    if [ -d "$src" ]; then
      rsync -a --delete --filter=":- $EXCLUDE" "$src/" "$dst/"
    else
      rsync -a --filter=":- $EXCLUDE" "$src" "$dst"
    fi
  else
    if [ -d "$src" ]; then
      rm -rf "$dst"
      cp -a "$src" "$dst"
    else
      cp -f "$src" "$dst"
    fi
  fi
}

while IFS=: read -r src dst; do
  [[ -z $src || $src == \#* ]] && continue
  copy_one "$src" "$dst"
done <"$MAP"

echo "Done copying to configCopy"

