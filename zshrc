bindkey -v

# ────── Color Codes ──────
RED="%F{red}"
GREEN="%F{green}"
YELLOW="%F{yellow}"
BLUE="%F{blue}"
PURPLE="%F{magenta}"
CYAN="%F{cyan}"
WHITE="%F{white}"
BOLD="%B"
RESET="%f%b%k"
BRBLACK="%F{black}"

# ────── OS Icon ──────
prompt_os() {
  if [[ "$(uname)" == "Linux" ]]; then
    if grep -qi microsoft /proc/version 2>/dev/null; then
      echo ""
    else
      echo ""
    fi
  elif [[ "$(uname)" == "Darwin" ]]; then
    echo ""
  else
    echo ""
  fi
}

# ────── Directory Symbol ──────
prompt_symbol_directory() {
  case "$PWD" in
    $HOME) echo " " ;;
    $HOME/*) echo " " ;;
    /etc*) echo "⚙️ " ;;
    *) echo "🔒 " ;;
  esac
}

# ────── Git Status ──────
prompt_git() {
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "(detached)")
    echo -n "$GREEN$branch$RESET"
  fi
}

# ────── VPN ──────
prompt_vpn() {
  if ip link show tun0 &>/dev/null || ip link show wg0 &>/dev/null; then
    echo "${GREEN}🔒 VPN${RESET}"
  else
    echo "${RED}🔒 No VPN${RESET}"
  fi
}

# ────── Time ──────
prompt_time() {
  echo " $(date +%T)"
}

# ────── Final Prompt ──────
build_prompt() {
  local exit_code=$?
  PS1="$PURPLE╭─ $(prompt_os) $CYAN$(prompt_symbol_directory)${PWD/#$HOME/~} $(prompt_git) $(prompt_vpn) $BRBLACK$(prompt_time)$RESET"$'\n'
  if [[ $exit_code -eq 0 ]]; then
    PS1+="${PURPLE}╰─❯ ${RESET}"
  else
    PS1+="${RED}╰─❯ ${RESET}"
  fi
}
precmd() { build_prompt }

# ────── ls colors ──────
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# ────── Syntax Highlighting ──────

ZSH_SYNTAX=~/.zsh-syntax-highlighting
ZSH_AUTOSUGGEST=~/.zsh-autosuggestions
ZSH_AUTOCOMPLETE=~/.zsh-autocomplete

clone_if_missing() {
  local dir=$1
  local repo=$2
  if [[ ! -d $dir ]]; then
    git clone "$repo" "$dir" &>/dev/null
  fi
}

clone_if_missing $ZSH_SYNTAX https://github.com/zsh-users/zsh-syntax-highlighting.git
clone_if_missing $ZSH_AUTOSUGGEST https://github.com/zsh-users/zsh-autosuggestions
clone_if_missing $ZSH_AUTOCOMPLETE https://github.com/marlonrichert/zsh-autocomplete.git

[[ -f $ZSH_SYNTAX/zsh-syntax-highlighting.zsh ]] && source $ZSH_SYNTAX/zsh-syntax-highlighting.zsh
[[ -f $ZSH_AUTOSUGGEST/zsh-autosuggestions.zsh ]] && source $ZSH_AUTOSUGGEST/zsh-autosuggestions.zsh
[[ -f $ZSH_AUTOCOMPLETE/zsh-autocomplete.plugin.zsh ]] && source $ZSH_AUTOCOMPLETE/zsh-autocomplete.plugin.zsh


# ────── Your scripts/bin dir ──────
export PATH="$HOME/.linux-setup/bin:$PATH"
