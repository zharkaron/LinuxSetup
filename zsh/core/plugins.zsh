# ~/.config/zsh/core/plugins.zsh
# This file loads all Zsh plugins from ~/.config/zsh/plugins/

PLUGIN_DIR="$ZSH_ROOT/plugins"

# zsh-autosuggestions
if [[ -f "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# zsh-history-substring-search (load before syntax-highlighting)
if [[ -f "$PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
  source "$PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh"
  # Up/down arrows filter history by what you've already typed
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# zsh-syntax-highlighting (must load last)
if [[ -f "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
