#!/usr/bin/env bash
set -euo pipefail

# cd to the real cwd of the tmux pane (or current shell)
p="$(tmux display -p '#{pane_current_path}' 2>/dev/null || pwd)"
cd "$p" || { echo "cd failed: $p"; exit 1; }

# pick a remote: origin if present, else first remote
url="$(git remote get-url origin 2>/dev/null || git remote get-url "$(git remote 2>/dev/null | head -n1)" 2>/dev/null || true)"
[ -n "${url:-}" ] || { echo "No git remote found."; exit 1; }

# normalize SSH -> https for common hosts; drop trailing .git
norm(){
  local u="$1"
  case "$u" in
    git@*:*) u="${u#git@}"; u="${u/:/\/}"; u="https://$u" ;;
    ssh://git@*/*) u="${u#ssh://git@}"; u="https://$u" ;;
  esac
  u="${u%.git}"
  printf '%s\n' "$u"
}

open_url(){
  local u="$1"
  # If running on WSL and wslview exists, use it; otherwise prefer xdg-open.
  if command -v wslview >/dev/null 2>&1; then wslview "$u" && return 0; fi
  if command -v xdg-open >/dev/null 2>&1; then xdg-open "$u" >/dev/null 2>&1 & disown; return 0; fi
  # last resort: print URL so user can copy
  echo "$u"
}

u="$(norm "$url")"
case "$u" in
  https://github.com/*|https://gitlab.com/*|https://bitbucket.org/*) open_url "$u" ;;
  *) echo "Repo host not recognized for browser open: $u"; exit 1 ;;
esac
