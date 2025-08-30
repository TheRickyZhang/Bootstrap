set -euo pipefail
#!/usr/bin/env bash
REPO="$(
  cd "$(dirname "$0")/../.."
  pwd
)"
CFG="$REPO/wsl/config"
MAP="$REPO/wsl/deps/config.map"

[ -f "$MAP" ] || {
  echo "missing $MAP"
  exit 1
}
mkdir -p "$CFG"

copy_one() {
  src="$1"
  dst="$2"
  src="${src/#\~/$HOME}"
  mkdir -p "$(dirname "$CFG/$dst")"
  if command -v rsync >/dev/null; then
    if [ -d "$src" ]; then
      rsync -a --delete "$src"/ "$CFG/$dst"/
    else
      rsync -a "$src" "$CFG/$dst"
    fi
  else
    if [ -d "$src" ]; then
      rm -rf "$CFG/$dst"
      cp -a "$src" "$CFG/$dst"
    else
      cp -f "$src" "$CFG/$dst"
    fi
  fi
}

while IFS= read -r line; do
  case "$line" in "" | "#"*) continue ;; esac
  src="${line%%:*}"
  dst="${line#*:}"
  copy_one "$src" "$dst"
done <"$MAP"

cd "$REPO"
git add -A
git commit -m "${1:-snapshot}" || true
git push -u origin HEAD:main
