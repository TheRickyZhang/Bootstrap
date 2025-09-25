#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.."; pwd)"
CONFIG_COPY="$ROOT/configCopy"
DEPS="$ROOT/deps"
DEPS_ARCH="$DEPS/arch"
MAP="$DEPS/configmap.txt"

debug(){ echo -e "\033[31m$*\033[0m"; }
[ -f "$MAP" ] || { debug "missing $MAP"; exit 1; }

pkg_update(){ sudo pacman -Syu --noconfirm; }
pkg_install(){ sudo pacman -S --needed --noconfirm "$@"; }

install_tmux_latest(){
  debug "building latest tmux"
  pkg_install git base-devel pkgconf autoconf automake bison libevent ncurses libutempter
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  git clone --depth=1 https://github.com/tmux/tmux.git "$tmp/tmux"
  cd "$tmp/tmux"; sh autogen.sh 2>/dev/null || true; ./configure; make -j"$(nproc)"; sudo make install
  debug "tmux: $(tmux -V)"
}

import_all(){
  rsync -a --itemize-changes "$CONFIG_COPY/" "$HOME/.config/"
  while IFS=: read -r dst src; do
    dst="$(echo "$dst"|xargs)"; src="$(echo "$src"|xargs)"
    [[ $dst == \#* || -z $src ]] && continue
    cp -r "$CONFIG_COPY/$src" "$HOME/$dst"
  done <"$MAP"
}

ensure_aur_helper(){
  if command -v paru >/dev/null 2>&1; then AUR_HELPER=paru; return; fi
  if command -v yay  >/dev/null 2>&1; then AUR_HELPER=yay;  return; fi
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  sudo pacman -S --needed --noconfirm base-devel git
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  AUR_HELPER=yay
}

install_aur_list(){
  local f="$1"
  [ -s "$f" ] || return 0
  ensure_aur_helper
  mapfile -t pkgs < <(grep -vE '^\s*(#|//|--|$)' "$f" | xargs -r -n1 echo)
  [ "${#pkgs[@]}" -gt 0 ] && "$AUR_HELPER" -S --needed --noconfirm "${pkgs[@]}"
}

debug "arch mode"
pkg_update

if [ "${FORCE_BUILD_TMUX:-0}" = 1 ]; then
  install_tmux_latest
elif command -v tmux >/dev/null; then
  debug "tmux present: $(tmux -V)"
else
  install_tmux_latest
fi

# official repo packages: deps/arch/pacman.txt
if [ -s "$DEPS_ARCH/pacman.txt" ]; then
  mapfile -t pkgs < <(grep -vE '^\s*(#|//|--|$)' "$DEPS_ARCH/pacman.txt" | xargs -r -n1 echo | sort -u)
  [ "${#pkgs[@]}" -gt 0 ] && pkg_install "${pkgs[@]}"
else
  debug "no deps/arch/pacman.txt"
fi

# optional AUR packages: deps/arch/aur.txt
install_aur_list "$DEPS_ARCH/aur.txt"

read -p "Overwrite ~/.config + mapped paths? (y/n): " y
[[ $y == y ]] || { echo Aborted.; exit 1; }
import_all

# bob (Neovim): excluded since arch up to date anyway
# if [ -s "$DEPS/nvim-versions.txt" ]; then
#   command -v cargo >/dev/null || { curl -fsSL https://sh.rustup.rs | sh -s -- -y; . "$HOME/.cargo/env"; }
#   command -v bob   >/dev/null || cargo install --locked bob-nvim || cargo install --git https://github.com/MordechaiHadad/bob.git --locked
#   export PATH="$HOME/.local/share/bob/nvim-bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"; hash -r
#   while read -r v; do v="${v%%#*}"; v="$(echo "$v"|xargs)"; [ -n "$v" ] && (bob install "$v" >/dev/null 2>&1 || bob install "$v"); done <"$DEPS/nvim-versions.txt"
#   last="$(grep -v '^\s*$' "$DEPS/nvim-versions.txt" | tail -n1 | sed 's/#.*//;s/^[[:space:]]*//;s/[[:space:]]*$//')"
#   [ -n "$last" ] && bob use "$last"
#   debug "bob done"
# else
#   debug "no nvim-versions.txt"
# fi

# npm (nvm)
if [ -s "$DEPS/npm.txt" ]; then
  command -v nvm >/dev/null || { export PROFILE="$HOME/.bashrc"; curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; }
  export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts; nvm alias default 'lts/*'
  xargs -r -a "$DEPS/npm.txt" -I{} npm i -g {}
fi

# cargo
if [ -s "$DEPS/cargo.txt" ]; then
  command -v cargo >/dev/null || { curl -fsSL https://sh.rustup.rs | sh -s -- -y; . "$HOME/.cargo/env"; }
  xargs -r -a "$DEPS/cargo.txt" -I{} cargo install -f {}
fi

# pipx
if [ -s "$DEPS/pipx.json" ]; then
  command -v pipx >/dev/null || pkg_install python-pipx
  grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  . "$HOME/.bashrc" || true; pipx ensurepath || true
  jq -r '.venvs | keys[]' "$DEPS/pipx.json" | xargs -r -I{} pipx install {}
fi

nvim --headless "+silent! Lazy! sync" +qa 2>/dev/null || true
debug "done (arch)"
