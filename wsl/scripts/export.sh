#!/usr/bin/env bash
set -euo pipefail

REPO="$(
  cd "$(dirname "$0")/../.."
  pwd
)"
CFG="$REPO/wsl/config"
MAP="$REPO/wsl/deps/configmap.txt"

[ -f "$MAP" ] || {
  echo "missing $MAP"
  exit 1
}
mkdir -p "$CFG"

copy_one() {
  src="$HOME/$1"
  dst="$CFG/$2"
  mkdir -p "$(dirname "$dst")"

  if command -v rsync >/dev/null; then
    if [ -d "$src" ]; then
      rsync -a --delete "$src"/ "$dst"/
    else
      rsync -a "$src" "$dst"
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

echo "Done! Make sure to push changes to repo so other devices can sync"
