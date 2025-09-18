#!/usr/bin/env bash
# trap 'tmux display-message "[err] failed at line $LINENO"; read -rp "Press enter to exit..."' ERR
set -euo pipefail

# Debug mode
set -x

# Single = only include these exactly, multi = include these and all subdirs one layer down
SINGLE_DIRS=(
  "$HOME"
  "$HOME/email"
  "$HOME/downloads"
  "$HOME/drive"
  "$HOME/drive/job"
  "$HOME/bin"
  "$HOME/.config"
  "$HOME/.config/nvim/lua"
)
MULTI_DIRS=(
  "$HOME/bootstrap"
  "$HOME/documents"
  "$HOME/job"
  "$HOME/projects"
  "$HOME/opensource"
  "$HOME/notes"
)

# ensure tmux server
tmux start-server >/dev/null 2>&1 || true

if [[ $# -eq 1 ]]; then
  selected="${1/#\~/$HOME}"
  [[ -d "$selected" ]] || {
    echo "[err] no such dir: $selected" >&2
    exit 1
  }
  selected="$(cd "$selected" && pwd -P)"
else
  # The boolean stops before >, >dev/null 2>&1 is just idiomatic way to say ignore the output. Remember this!
  finder=()
  if command -v sk >/dev/null 2>&1; then
    finder=(sk --margin 10% --color bw)
  elif command -v fzf >/dev/null 2>&1; then
    finder=(fzf --margin=10% --color=bw)
    [[ -o xtrace ]] && echo "[warn] using fzf (skim not installed)" >&2
  else
    echo "[err] no finder installed" >&2
    exit 1
  fi

  # make sure to collect ABSOLUTE candidates
  mapfile -t candidates < <(
    {
      # roots: SINGLE + MULTI (canonicalized)
      for d in "${SINGLE_DIRS[@]/#\~/$HOME}" "${MULTI_DIRS[@]/#\~/$HOME}"; do
        [[ -d $d ]] && (cd "$d" && pwd -P)
      done
      # one level down for MULTI (guard if empty to avoid searching cwd)
      ((${#MULTI_DIRS[@]})) && fd . "${MULTI_DIRS[@]/#\~/$HOME}" -t d -d 1 --absolute-path
    } 2>/dev/null | awk '!seen[$0]++'
  )
  [[ ${#candidates[@]} -eq 0 ]] && exit 0

  # show them with shortened ~ for display only
  picked=$(
    printf "%s\n" "${candidates[@]}" |
      sed "s|^$HOME|~|" |
      "${finder[@]}"
  )

  # map back to absolute, verify, canonicalize
  [[ -n "$picked" ]] || exit 0
  selected="${picked/#\~/$HOME}"
  [[ -d "$selected" ]] || {
    echo "[err] no such dir: $selected" >&2
    exit 1
  }
  selected="$(cd "$selected" && pwd -P)"
fi # show them with shortened ~ for display only

[[ -z "${selected:-}" ]] && exit 0

# tmux session names can’t contain dots
selected_name=$(basename "$selected" | tr '.: ' '___')

if tmux has-session -t "$selected_name" 2>/dev/null; then
  # try to find a window in this session already at that path
  win_id=$(tmux list-panes -t "$selected_name:" -F "#{window_id} #{pane_active} #{pane_current_path}" |
    awk -v p="$selected" '$2=="1" && $3==p {print $1; exit}')
  if [[ -n "$win_id" ]]; then
    tmux select-window -t "$win_id"
  else
    win_id=$(tmux new-window -P -F "#{window_id}" -t "$selected_name:" -c "$selected" -n "$(basename "$selected")")
    tmux select-window -t "$win_id"
  fi
else
  tmux new-session -ds "$selected_name" -c "$selected"
fi

# switch/attach to the session (the active window is already set)
if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$selected_name"
else
  tmux attach -t "$selected_name"
fi
