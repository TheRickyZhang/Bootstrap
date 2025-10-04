# interactive guard
case $- in *i*) ;; *) return ;; esac

# paths (user-first)
export PATH="$HOME/.local/bin:$PATH"

# optional: Cargo/Bob (only if installed)
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"

# editor + XDG
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# GPG over TTY
export GPG_TTY="$(tty)"

# optional: Go (Arch's default GOPATH is ~/go; override if you prefer)
# export GOPATH="$HOME/.local/go"
# export GOBIN="$HOME/.local/bin"

# optional: bun (only if installed)
# export BUN_INSTALL="$HOME/.bun"
# export PATH="$BUN_INSTALL/bin:$PATH"

# direnv (if installed)
command -v direnv >/dev/null && eval "$(direnv hook bash)"

# completion (if bash-completion is installed)
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
