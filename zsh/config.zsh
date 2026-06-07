# LinuxSetup Machine-Specific Configuration
# ==========================================
# Override any of these defaults by exporting the variable before running a
# script, or by placing `export VAR=value` in ~/.zshrc.local (included below).
#
# ┌─────────────────────────────────────────────────────────────────────┐
# │ All variables listed here are OPTIONAL – scripts fail with a clear  │
# │ message when a required value is missing.                           │
# └─────────────────────────────────────────────────────────────────────┘

# sshcmd – remote host + directory to forward commands to
#   export LINUXSETUP_SSH_HOST=myserver
#   export LINUXSETUP_SSH_DIR=/home/user/docker
export LINUXSETUP_SSH_HOST="${LINUXSETUP_SSH_HOST:-Server}"
export LINUXSETUP_SSH_DIR="${LINUXSETUP_SSH_DIR:-/home/zhark/docker}"

# docker-up / docker-d – remote docker host + compose directory
#   export LINUXSETUP_DOCKER_HOST=mydocker
#   export LINUXSETUP_DOCKER_DIR=~/docker
export LINUXSETUP_DOCKER_HOST="${LINUXSETUP_DOCKER_HOST:-mydocker}"
export LINUXSETUP_DOCKER_DIR="${LINUXSETUP_DOCKER_DIR:-~/docker}"

# katmode – xinput device ID for the touchscreen
#   export LINUXSETUP_KATMODE_DEVICE=9          # explicit ID
#   export LINUXSETUP_KATMODE_DEVICE=auto       # auto-detect (default)
export LINUXSETUP_KATMODE_DEVICE="${LINUXSETUP_KATMODE_DEVICE:-auto}"

# update_ssh – GitHub user whose SSH keys are trusted
#   export LINUXSETUP_GITHUB_USER=zh4rkaron
export LINUXSETUP_GITHUB_USER="${LINUXSETUP_GITHUB_USER:-zh4rkaron}"

# ──────────────────────────────────────────────────────────────────────
# Local overrides (ignored by git)
# ──────────────────────────────────────────────────────────────────────
if [[ -f "$ZSH_ROOT/config.local.zsh" ]]; then
  source "$ZSH_ROOT/config.local.zsh"
fi
