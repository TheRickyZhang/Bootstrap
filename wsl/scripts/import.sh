#!/usr/bin/env bash
set -euo pipefail
REPO="$(
  cd "$(dirname "$0")/../.."
  pwd
)"
CFG="$REPO/wsl/config"
DEPS="$REPO/wsl/deps"
MAP="$DEPS/configmap.txt"

debug() { echo -e "\033[31m$*\033[0m"; }

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
fi

debug "done installing"
# Pin Neovim version via bob (optional: keep nvim-version.txt like "0.10.2")
if [ -s "$DEPS/nvim-versions.txt" ]; then
  # command is pretty sparse, -v = view; just simulate the output of a ru.n
  # but command is also tricky. If we do -v ls, an external executable, it prints the file path
  debug "managing neovim versions via bob"
  # We can generally measure whether some name is resolvable reliably
  # But otherwise like for -v cd, it just echoes
  if ! command -v bob >/dev/null; then
    if command -v cargo >/dev/null; then
      debug "installing bob via cargo"
      cargo install bob-nvim || true
    else
      debug "installing bob from github"
      curl -fsSL https://raw.githubusercontent.com/MordechaiHadad/bob/master/install.sh | bash
    fi
  fi

  while read ver; do
    [ -n "$ver" ] || continue
    # Equivalent to: if ! [ -n ver ]; then continue fi, but || continue is pretty idiomatic
    bob install "$ver"
  done \
    <"$DEPS/nvim-versions.txt"
  # Note for more conventional order we may prefix with cat "DEPS/nvim-versions.txt | " instead
  # There is only a small difference where while loop runs in an inner scope

  # By default tail gets the last 10 lines, we only want one line
  lastver=$(tail -n1 "$DEPS/nvim-versions.txt")
  bob use "$lastver"
  debug "done managing neovim versions"
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
fi

# pipx apps (For CLIs and isolated dependency management)
if [ -s "$DEPS/pipx.json" ]; then
  debug "managing pipx dependencies"
  # -m -> run library module as script, -U -> upgrade
  python3 -m pip install --user -U pipx
  pipx ensurepath || true
  # '.venvs | keys[]' means look at the keys under the .venvs root attribute
  # -I{} -> infer arguments, it is required here over default behavior since we have 2 in different places
  # we don't use -a (arguments) here, but instead pipe with converted stdout from jq
  jq -r '.venvs | keys[]' "$DEPS/pipx.json" | xargs -r -I{} pipx install {}
  debug "managing pipx dependencies"
fi

# copy repo configs -> real locations (backup if exists)
[ -f "$MAP" ] || {
  debug "missing $MAP"
  exit 1
}

# Note that this function is written in context to input piped from the file BELOW
# $1, $2, etc are special variables for the arguments of the script (ie ./script $1 $2), but in this case the function is called with the line variables
debug "reading config from map"

ts="$(date +%Y%m%d%H%M%S)"
deploy_one() {
  src="$CFG/$1"
  dst="${2/#\~/$HOME}"
  # This makes the parent, so it is not redundant
  mkdir -p "$(dirname "$dst")"

  # Move any existing files to a backup
  if [ -e "$dst" ]; then
    mv "$dst" "${dst}.bak.$ts" 2>/dev/null || true
    # rsync -a (archive mode, preserve everything) is the same as cp, just for directories
  fi
  if [ -d "$src" ]; then
    rsync -a "$src"/ "$dst"/
  else
    cp -f "$src" "$dst"
  fi
}
# We don't need it here, but IFS (internal field separator) and -r basically read raw lines directly without trimming or escaping
while IFS= read -r line; do
  case "$line" in "" | "#"*) continue ;; esac
  # var#pattern -> remove match of pattern from front/end
  real="${line%%:*}" # A double % ensures we take from the first : (since it will produce longest string), though doesn't matter if only one : present
  rel="${line#*:}"
  deploy_one "$rel" "$real"
done <"$MAP"

# optional: nvim plugin sync (no-op if not using Lazy/packer)
nvim --headless "+silent! Lazy! sync" +qa 2>/dev/null || true

# NeoMutt
debug "preparing neomutt"

mkdir -p ~/.config/mutt ~/.config/msmtp ~/.local/bin ~/Mail
# helpful defaults
update-ca-certificates || true

debug "import complete."
