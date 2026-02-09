# Load colors
source ~/.LinuxSetup/zsh/themes/colors.zsh

# Distro icons
typeset -A DISTRO_ICON_MAP=(
  [ubuntu]=""
  [debian]=""
  [fedora]=""
  [arch]=""
  [manjaro]=""
  [pop]=""
)

get_distro_icon() {
  if [[ -f /etc/os-release ]]; then
    local id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    echo ${DISTRO_ICON_MAP[$id]:-}
  else
    echo ""
  fi
}

git_branch() {
  local branch
  branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
  [[ -n $branch ]] && echo "(${MAGENTA}$branch${RESET})"
}

prompt_arrow() {
  echo "${GRAY}──${BLUE}>${RESET}"
}

UBUNTU_ICON="$(get_distro_icon)"

setopt prompt_subst   # <--- THIS FIXES YOUR ISSUE

# First line
PROMPT_LINE1='${GRAY}╭${RESET} '"${UBUNTU_ICON}"' ${GREEN}%n${RESET}@${BLUE}%m${RESET} ${YELLOW}%~${RESET} $(git_branch)'

# Second line
PROMPT_LINE2='${GRAY}╰'"$(prompt_arrow)"' '

PROMPT="${PROMPT_LINE1}
${PROMPT_LINE2}"
