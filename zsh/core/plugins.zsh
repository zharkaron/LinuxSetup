# ~/.config/zsh/core/plugins.zsh
# This file loads all Zsh plugins from ~/.config/zsh/plugins/

PLUGIN_DIR="$HOME/.LinuxSetup/zsh/plugins"

# zsh-autosuggestions
if [[ -f "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# zsh-syntax-highlighting (must load last)
if [[ -f "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
