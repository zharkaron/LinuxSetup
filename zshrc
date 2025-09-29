# Set PATH
export PATH="$HOME/.LinuxSetup/bin:$PATH"

# Aliases for frequently used commands
alias ls='ls --color=auto'
alias la='ls -a --color=auto'
alias ll='ls -l --color=auto'
alias lla='ls -la --color=auto'
alias gpull='git pull'
alias gmail='git checkout main'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Enable command auto-correction
ENABLE_CORRECTION="true"

# Enable command completion
autoload -Uz compinit
compinit

# Load the plugins (syntax highlighting and autosuggestions)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

ZSH_THEME="powerlevel10k/powerlevel10k"

# command prompt fix
# Enable colors for the prompt
autoload -U colors && colors

# Function to get Git branch info
git_prompt_info() {
  local git_branch
  git_branch=$(git symbolic-ref HEAD 2>/dev/null) || return
  git_branch=${git_branch#refs/heads/}
  echo "($git_branch)"
}

# Set the left prompt (current user, host, directory, Git status)
PROMPT='%{$fg[cyan]%}%n@%m %{$fg[green]%}%~ %{$fg[yellow]%}$(git_prompt_info)%{$reset_color%} '

# Set the right prompt (time, or any other info)
RPROMPT='%{$fg[red]%}%*%{$reset_color%}'

# Enable prompt substitution (allows for dynamic updates to the prompt)
setopt prompt_subst

