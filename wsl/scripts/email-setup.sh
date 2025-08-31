#!/usr/bin/env bash
set -euo pipefail

debug() { printf '\033[31m%s\033[0m\n' "$*"; }

mkdir -p "$HOME/.local/bin" "$HOME/.config/vybr" "$HOME/.local/src"

# ensure ~/.local/bin on PATH
case ":$PATH:" in *":$HOME/.local/bin:"*) ;;
*)
  export PATH="$HOME/.local/bin:$PATH"
  grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" ||
    printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >>"$HOME/.bashrc"
  ;;
esac

debug "cloning/building vygrant"
if [ ! -d "$HOME/.local/src/vygrant" ]; then
  git clone https://github.com/vybraan/vygrant.git "$HOME/.local/src/vygrant"
else
  git -C "$HOME/.local/src/vygrant" pull --ff-only || true
fi

cd "$HOME/.local/src/vygrant"
go build -ldflags "-s -w" -o "$HOME/.local/bin/vygrant" || {
  echo "vygrant build failed"
  exit 1
}

debug "vygrant check"
vygrant --version || true
vygrant status || true # daemon may not be running yet; this is just informational

# TODO: refresh/login for your account when ready

# SMTP note (leave as-is if already set):
# chmod 600 "$HOME/.msmtprc" 2>/dev/null || true
