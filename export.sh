#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
CONFIG_COPY="$REPO/configCopy"
MAP="$REPO/deps/configmap.txt"
GITIGNORE="$REPO/.gitignore"

[ -f "$MAP" ] || { echo "missing $MAP"; exit 1; }
mkdir -p "$CONFIG_COPY"

# Collect ignore patterns from .gitignore entries starting with "configCopy/"
IGNORED_DEST=()
if [ -f "$GITIGNORE" ]; then
  while IFS= read -r line; do
    line="${line%%#*}"              # strip trailing comments
    line="$(echo "$line" | xargs)"  # trim
    [[ -z "$line" ]] && continue
    case "$line" in
      configCopy/*)
        pat="${line#configCopy/}"   # make it relative to configCopy/
        pat="${pat%/**}"            # drop trailing /** if present
        pat="${pat%/}"              # drop trailing / if present
        [ -n "$pat" ] && IGNORED_DEST+=("$pat")
        ;;
    esac
  done <"$GITIGNORE"
fi

is_ignored_dest(){ # $1 = path relative to configCopy
  local d="$1"
  d="${d#./}"
  d="${d#configCopy/}"
  for pat in "${IGNORED_DEST[@]}"; do
    case "$d" in
      "$pat"|"$pat"/*) return 0 ;;
    esac
  done
  return 1
}

RSYNC_EXCLUDES=()
for pat in "${IGNORED_DEST[@]}"; do
  RSYNC_EXCLUDES+=(--exclude="$pat" --exclude="$pat/**")
done

# bulk export ~/.config -> $CONFIG_COPY/
rsync -a --delete --itemize-changes \
  "${RSYNC_EXCLUDES[@]}" \
  "$HOME/.config/" "$CONFIG_COPY/"

copy_one() {
  local raw="$1"
  local rel="$2"

  if is_ignored_dest "$rel"; then
    echo "skip $rel (gitignored)"
    return 0
  fi

  local dst="$CONFIG_COPY/$rel"

  case "$raw" in
    "~")   src="$HOME" ;;
    ~/*)   src="$HOME/${raw#~/}" ;;
    /*)    src="$raw" ;;              # absolute system path like /etc/...
    *)     src="$HOME/$raw" ;;        # default: relative to $HOME
  esac

  [ -e "$src" ] || { echo "missing $src"; return 1; }
  mkdir -p "$(dirname "$dst")"

  if [ -d "$src" ]; then
    rsync -a --delete "${RSYNC_EXCLUDES[@]}" "$src/" "$dst/"
  else
    rsync -a "${RSYNC_EXCLUDES[@]}" "$src" "$dst"
  fi
}

while IFS=: read -r src dst; do
  [[ -z $src || $src == \#* ]] && continue
  copy_one "$src" "$dst"
done <"$MAP"

echo "Done copying to configCopy"

