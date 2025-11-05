# Enable syntax highlighting and autosuggestions
ZSH_HIGHLIGHT_DIR=${HOME}/.zsh-syntax-highlighting
ZSH_AUTOSUGGEST_DIR=${HOME}/.zsh-autosuggestions

# Load syntax highlighting if installed
if [ -f "$ZSH_HIGHLIGHT_DIR/zsh-syntax-highlighting.zsh" ]; then
    source "$ZSH_HIGHLIGHT_DIR/zsh-syntax-highlighting.zsh"
fi

# Load autosuggestions if installed
if [ -f "$ZSH_AUTOSUGGEST_DIR/zsh-autosuggestions.zsh" ]; then
    source "$ZSH_AUTOSUGGEST_DIR/zsh-autosuggestions.zsh"
fi

# Prompt
PROMPT='%F{green}%n@%m%f %F{blue}%~%f %# '

# Some useful options
setopt autocd           # Change dir by just typing dir name
setopt correct          # Spell correction
setopt nocaseglob       # Case-insensitive globbing

# Enable history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

