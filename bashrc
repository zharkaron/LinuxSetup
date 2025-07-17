# ────── Color Codes ──────
RED="\[\e[31m\]"
GREEN="\[\e[32m\]"
YELLOW="\[\e[33m\]"
BLUE="\[\e[34m\]"
PURPLE="\[\e[35m\]"
CYAN="\[\e[36m\]"
WHITE="\[\e[37m\]"
BOLD="\[\e[1m\]"
RESET="\[\e[0m\]"
BRBLACK="\[\e[90m\]"

# ────── OS Icon ──────
function prompt_os() {
  local uname_out=$(uname)
  if [[ "$uname_out" == "Linux" ]]; then
    if grep -qi microsoft /proc/version 2>/dev/null; then
      echo -ne "${WHITE}${RESET}"  # WSL icon
    else
      echo -ne "${BOLD}${WHITE}${RESET}"  # Linux icon
    fi
  elif [[ "$uname_out" == "Darwin" ]]; then
    echo -ne "${BOLD}${WHITE}${RESET}"  # macOS icon
  elif [[ "$uname_out" == *"CYGWIN"* || "$uname_out" == *"MINGW"* || "$uname_out" == *"MSYS"* ]]; then
    echo -ne "${WHITE}${RESET}"  # Windows icon
  fi
}

# ────── Directory Symbol ──────
function prompt_symbol_directory() {
  local pwd=$(pwd)
  if [[ "$pwd" == "$HOME" ]]; then
    echo -ne " "  # Home icon
  elif [[ "$pwd" == "$HOME/"* ]]; then
    echo -ne " "  # Home subdirectory icon
  elif [[ "$pwd" == /etc* ]]; then
    echo -ne "⚙️ "  # Gear icon
  else
    echo -ne "🔒 "  # Lock icon
  fi
}

# ────── Path ──────
function prompt_path() {
  local pwd=$(pwd)
  if [[ "$pwd" == "$HOME" ]]; then
    echo -ne "~"
  elif [[ "$pwd" == "$HOME/"* ]]; then
    echo -ne "~/${pwd#$HOME/}"
  else
    echo -ne "$pwd"
  fi
}

# ────── Git branch and status ──────
function prompt_git() {
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z $branch ]] && branch="(detached)"

  local added=0 modified=0 deleted=0 conflicted=0

  while read -r line; do
    [[ "$line" == \#* ]] && continue

    local first_char="${line:2:1}"
    local second_char="${line:3:1}"

    if [[ "$first_char" == "U" || "$second_char" == "U" ]]; then
      ((conflicted++))
      continue
    fi

    if [[ "$first_char" =~ [AMRC] ]]; then
      ((added++))
    elif [[ "$first_char" == "D" ]]; then
      ((deleted++))
    fi

    if [[ "$second_char" =~ [MT] ]]; then
      ((modified++))
    elif [[ "$second_char" == "D" ]]; then
      ((deleted++))
    fi
  done < <(git status --porcelain=2 --branch)

  echo -ne "${GREEN}${branch} "

  [[ $added -gt 0 ]] && echo -ne "${YELLOW}+${added} "
  [[ $modified -gt 0 ]] && echo -ne "${YELLOW}~${modified} "
  [[ $deleted -gt 0 ]] && echo -ne "${YELLOW}-${deleted} "
  [[ $conflicted -gt 0 ]] && echo -ne "${YELLOW}✗${conflicted} "
}

# ────── VPN status ──────
function prompt_vpn() {
  if ip link show tun0 &>/dev/null || ip link show wg0 &>/dev/null; then
    echo -ne "${GREEN}🔒 VPN${RESET} "
  else
    echo -ne "${RED}🔒 No VPN${RESET} "
  fi
}

# ────── Current time ──────
function prompt_time() {
  echo -ne " $(date +%T)"
}

# ────── Set Bash Prompt ──────
function set_bash_prompt() {
  local EXIT="$?"

  PS1="${PURPLE}╭─ $(prompt_os)${CYAN} $(prompt_symbol_directory)$(prompt_path) $(prompt_git)$(prompt_vpn)${BRBLACK} $(prompt_time)${RESET}\n"

  if [ $EXIT -eq 0 ]; then
    PS1+="${PURPLE}╰─❯ ${RESET}"
  else
    PS1+="${RED}╰─❯ ${RESET}"
  fi
}

PROMPT_COMMAND=set_bash_prompt

# ────── Enable color support for 'ls' etc (optional) ──────
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# ────── Optional: Syntax highlighting setup ──────
# Uncomment these lines after you clone bash-syntax-highlighting repo:
# git clone https://github.com/jimeh/bash-syntax-highlighting.git ~/.bash-syntax-highlighting
# echo 'source ~/.bash-syntax-highlighting/bash-syntax-highlighting.sh' >> ~/.bashrc

#coloring on ls
alias ls='ls --color=auto'

alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# Auto-install ble.sh if it's not present
if [ ! -f ~/.local/share/blesh/ble.sh ]; then
  echo "Installing ble.sh..."
  git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git ~/ble.sh && \
  make -C ~/ble.sh install PREFIX=$HOME/.local && \
  rm -rf ~/ble.sh
fi

export PATH="$HOME/.linux-setup/bin:$PATH"

# Source ble.sh
if [ -f ~/.local/share/blesh/ble.sh ]; then
  source ~/.local/share/blesh/ble.sh
fi
