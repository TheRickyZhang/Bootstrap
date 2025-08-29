cd $(tmux run "echo #{pane_current_path}")

url=$(git remote get-url origin)

if [[ "$OSTYPE" == "darwin"* ]]; then
  open "$url" || echo "No remote found found for MacOS"
elif grep -qi microsoft /proc/version 2>/dev/null; then
  wslview $url || echo "No remote found for WSL"
else
  xdg-open "$url" || echo "No remote found for XDG"
fi
