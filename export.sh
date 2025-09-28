#!/usr/bin/env bash
set -euo pipefail

# Use arg 1 or error (using 1- would be used to supply empty argument instead of erroring)
# MESSAGE="${1:?missing message}"

REPO="$(
  cd "$(dirname "$0")"
  pwd
)"
CONFIG_COPY="$REPO/configCopy"
MAP="$REPO/deps/configmap.txt"

[ -f "$MAP" ] || {
  echo "missing $MAP"
  exit 1
}
mkdir -p "$CONFIG_COPY"

# bulk export ~/.config -> $CONFIG_COPY/.config
rsync -a --delete --itemize-changes "$HOME/.config/" "$CONFIG_COPY/"

copy_one() {
  src="$HOME/$1"
  dst="$CONFIG_COPY/$2"
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

# cd "$REPO"
# git add -A :/
# git diff --cached --quiet && {
#   echo "no changes to commit"
#   exit 0
# }
# git commit -m "$MESSAGE"
# git push

echo "Done copying to configCopy"
