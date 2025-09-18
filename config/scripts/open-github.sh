#!/usr/bin/env bash
set -euo pipefail

p="$(tmux display -p '#{pane_current_path}' 2>/dev/null || pwd)"
echo "DEBUG pane cwd: [$p]"
cd "$p" || {
  echo "cd failed: $p"
  exit 1
}

url="$(git remote get-url origin 2>/dev/null || true)"
echo "DEBUG origin url: [${url:-<empty>}]"

if [[ -z "${url:-}" ]]; then
  echo "No origin remote (are you in a git repo?)"
  exit 1
fi

# If you only care about GitHub:
if [[ "$url" == *github.com* ]]; then
  # Normalize SSH → https so browsers open it nicely
  if [[ "$url" == git@* ]]; then
    url="${url#git@}"
    url="${url/:/\/}"
    url="https://$url"
  fi
  echo "DEBUG opening: $url"
  wslview "$url"
else
  echo "This repository is not hosted on GitHub (url: $url)"
fi
