#!/usr/bin/env bash
set -euo pipefail
REPO="$(
  cd "$(dirname "$0")/../.."
  pwd
)"
DEPS="$REPO/wsl/deps"

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y
[ -s "$DEPS/apt.txt" ] && xargs -r -a "$DEPS/apt.txt" sudo apt-get install -y --no-install-recommends

if [ -s "$DEPS/npm.txt" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" || true
  if command -v nvm >/dev/null; then
    cur="$(nvm current || echo none)"
    [ "$cur" = "none" ] && nvm install --lts || nvm install --lts --reinstall-packages-from="$cur"
    xargs -r -a "$DEPS/npm.txt" -I{} npm i -g {}
  fi
fi

if [ -s "$DEPS/pip-user.txt" ]; then
  python3 -m pip install --user -U pip wheel setuptools
  python3 -m pip install --user -U -r "$DEPS/pip-user.txt" || true
fi

if [ -s "$DEPS/cargo.txt" ] && command -v cargo >/dev/null; then
  xargs -r -a "$DEPS/cargo.txt" -I{} cargo install -f {}
fi

if [ -s "$DEPS/nvim-version.txt" ] && command -v bob >/dev/null; then
  ver="$(tr -d '\n' <"$DEPS/nvim-version.txt")"
  bob install "$ver" && bob use "$ver" || true
fi

nvim --headless "+silent! Lazy! sync" +qa 2>/dev/null || true
echo "update complete."
