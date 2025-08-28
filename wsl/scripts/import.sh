#!/usr/bin/env bash
set -euo pipefail
REPO="$(
  cd "$(dirname "$0")/../.."
  pwd
)"
CFG="$REPO/wsl/config"
DEPS="$REPO/wsl/deps"
MAP="$DEPS/config.map"

# base tools only (adjust if you want slimmer)
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  ca-certificates curl git build-essential unzip rsync jq \
  ripgrep fd-find neovim python3-pip

# apt packages from your manual list
[ -s "$DEPS/apt.txt" ] && xargs -r -a "$DEPS/apt.txt" sudo apt-get install -y --no-install-recommends

# Node via nvm + global npm (only if you keep npm.txt)
if [ -s "$DEPS/npm.txt" ]; then
  if ! command -v nvm >/dev/null; then
    export PROFILE="$HOME/.bashrc"
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*'
  xargs -r -a "$DEPS/npm.txt" -I{} npm i -g {}
fi

# pip user packages (only if you keep pip-user.txt)
if [ -s "$DEPS/pip-user.txt" ]; then
  python3 -m pip install --user -U pip wheel setuptools
  python3 -m pip install --user -r "$DEPS/pip-user.txt"
fi

# Rust + cargo installs (only if you keep cargo.txt)
if [ -s "$DEPS/cargo.txt" ]; then
  if ! command -v cargo >/dev/null; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    . "$HOME/.cargo/env"
  fi
  xargs -r -a "$DEPS/cargo.txt" -I{} cargo install -f {}
fi

# pipx apps (only if you keep pipx.json)
if [ -s "$DEPS/pipx.json" ]; then
  python3 -m pip install --user -U pipx
  pipx ensurepath || true
  # expects jq; install above
  jq -r '.venvs | keys[]' "$DEPS/pipx.json" | xargs -r -I{} pipx install {}
fi

# Pin Neovim version via bob (optional: keep nvim-version.txt like "0.10.2")
if [ -s "$DEPS/nvim-version.txt" ]; then
  ver="$(tr -d '\n' <"$DEPS/nvim-version.txt")"
  if ! command -v bob >/dev/null; then
    if command -v cargo >/dev/null; then
      cargo install bob-nvim || true
    else
      curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/install.sh | bash
    fi
  fi
  bob install "$ver" && bob use "$ver" || true
fi

# copy repo configs -> real locations (backup if exists)
[ -f "$MAP" ] || {
  echo "missing $MAP"
  exit 1
}
ts="$(date +%Y%m%d%H%M%S)"
deploy_one() {
  src="$1"
  dst="$2"
  src="$CFG/$src"
  dst="${dst/#\~/$HOME}"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -d "$dst" ]; then mv "$dst" "${dst}.bak.$ts" 2>/dev/null || true; fi
  if [ -d "$src" ]; then
    rsync -a "$src"/ "$dst"/
  else
    cp -f "$src" "$dst"
  fi
}
while IFS= read -r line; do
  case "$line" in "" | "#"*) continue ;; esac
  real="${line%%:*}"
  rel="${line#*:}"
  deploy_one "$rel" "$real"
done <"$MAP"

# optional: nvim plugin sync (no-op if not using Lazy/packer)
nvim --headless "+silent! Lazy! sync" +qa 2>/dev/null || true

echo "preparing neomutt"
set -euo pipefail

sudo apt update
sudo apt install -y \
  neomutt isync msmtp msmtp-mta w3m urlscan \
  python3 python3-venv python3-msal \
  sasl-xoauth2 ca-certificates \
  pinentry-curses git curl

# helpful defaults
mkdir -p ~/.config/mutt ~/.config/msmtp ~/.local/bin ~/Mail
update-ca-certificates || true

echo "import complete."
