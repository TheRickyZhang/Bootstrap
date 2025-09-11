#!/usr/bin/env bash
set -euo pipefail
ROOT="$(
  cd "$(dirname "$0")/../.."
  pwd
)"
CONFIG="$ROOT/wsl/config"
DEPS="$ROOT/wsl/deps"

MAP="$DEPS/configmap.txt"

debug() { echo -e "\033[31m$*\033[0m"; }

[ -f "$MAP" ] || {
  debug "missing $MAP"
  exit 1
}

# Defaults: copy everything under $CONFIG/.config -> ~/.config
import_all() {
  # rsync is a better way to bulk copy
  rsync -a --itemize-changes "$CONFIG/" "$HOME/.config/"

  # apply overrides from map file. Strip whitespace from components
  while IFS=: read -r local remote; do
    local=$(echo "$local" | xargs)
    remote=$(echo "$remote" | xargs)
    # Skip if comment or no colon
    [[ $local == \#* ]] && continue
    [[ -z $remote ]] && continue
    cp -r "$CONFIG/$remote" "$HOME/$local"
  done <"$MAP"
}

# All possible files in DEPS:
# Native Plugins:    apt
# Text Editors:      nvim-version (bob),
# Language-specific: npm, pip-user, cargo,

# [ ] shorthand for test, -s means exist and has size
# Note that other flags we can use are:
# -e (exists)
# -f (file), -d (dir)
# -r (readable), -w (writable)

debug "installing base tools"
# install base tools
sudo apt-get update

# Remember bash statements look at an error code
if [ -s "$DEPS/apt.txt" ]; then
  # Use xargs for converting stdout to discrete arguments (Note that -r is an optional guard to RETURN if the file is empty)
  # Normally you might see echo "a b c" | xargs command -> converted to command a b c,
  # but -a (arguments file) is a special way to do by reading from a file
  xargs -r -a "$DEPS/apt.txt" sudo apt-get install -y --no-install-recommends
else
  debug "apt.txt not found"
fi

debug "syncing configs"

# TODO: Originally this created backups if they existed but this is just a lot simpler
# How to await user input, -p means prompt
read -p "About to sync configs. This will overwrite anything you have in ~/.config \
  and additional elements in configmap.txt. Please confirm (y/n) to continue:" response
if [[ $response != y ]]; then
  echo "Aborted."
  exit 1
fi

debug "reading config from map"
import_all

# Pin Neovim version via bob
if [ -s "$DEPS/nvim-versions.txt" ]; then
  [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

  # ensure bob (via cargo; install rustup only if needed)
  if ! command -v bob >/dev/null 2>&1; then
    command -v cargo >/dev/null 2>&1 || {
      curl -fsSL https://sh.rustup.rs | sh -s -- -y
      . "$HOME/.cargo/env"
    }
    cargo install --locked bob-nvim || cargo install --git https://github.com/MordechaiHadad/bob.git --locked
  fi

  # system-wide PATH for bob + cargo; apply now
  sudo tee /etc/profile.d/bob.sh >/dev/null <<'EOF'
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export PATH="$HOME/.local/share/bob/nvim-bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
EOF
  . /etc/profile.d/bob.sh
  hash -r

  # install versions listed (skip blanks/comments), then activate the last one
  while IFS= read -r ver; do
    ver="${ver%%#*}"
    ver="$(printf "%s" "$ver" | xargs)"
    [ -n "$ver" ] || continue
    bob install "$ver" >/dev/null 2>&1 || bob install "$ver"
  done <"$DEPS/nvim-versions.txt"

  lastver="$(grep -v '^\s*$' "$DEPS/nvim-versions.txt" | tail -n1 | sed 's/#.*//;s/^[[:space:]]*//;s/[[:space:]]*$//')"
  [ -n "$lastver" ] && bob use "$lastver"
  debug "done with bob neovim"
else
  debug "nvim versoins / bob installation not found, this is pretty bad"
fi

# ------------------   Language Specific ------------------------
# Node
if [ -s "$DEPS/npm.txt" ]; then
  debug "managing npm dependencies"
  if ! command -v nvm >/dev/null; then
    # This is just something that node checks specifically for where to put come config
    export PROFILE="$HOME/.bashrc"
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  fi
  # This is the node virtual machine, NOT nvim
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts
  nvm alias default 'lts/*'
  xargs -r -a "$DEPS/npm.txt" -I{} npm i -g {}
  debug "done managing npm"
else
  debug "npm.txt not found"
fi

# Rust and Cargo
if [ -s "$DEPS/cargo.txt" ]; then
  debug "managing rust dependencies"
  if ! command -v cargo >/dev/null; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    . "$HOME/.cargo/env"
  fi
  xargs -r -a "$DEPS/cargo.txt" -I{} cargo install -f {}
  debug "done managing rust dependencies"
else
  debug "cargo.txt not found"
fi

# pipx apps (For CLIs and isolated dependency management)
if [ -s "$DEPS/pipx.json" ]; then
  debug "managing pipx dependencies"

  if ! command -v pipx >/dev/null; then
    sudo apt-get update
    sudo apt-get install -y pipx python3-venv
  fi

  grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc ||
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>~/.bashrc
  . ~/.bashrc

  pipx ensurepath || true

  # Install apps listed as venv keys in your pipx.json
  jq -r '.venvs | keys[]' "$DEPS/pipx.json" | xargs -r -I{} pipx install {}

  debug "done managing pipx dependencies"
else
  debug "pipx.json not found"
fi

nvim --headless "+silent! Lazy! sync" +qa 2>/dev/null || true # optional: nvim plugin sync (no-op if not using Lazy/packer)

debug "success!"

debug "please restart terminal to apply new path. Alternatiely, do: . /etc/profile.d/bob.sh; hash -r; type -a nvim; nvim --version | head -n1 "
