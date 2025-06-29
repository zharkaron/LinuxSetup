#!/bin/bash
GITHUB_USER="zh4rkaron"
AUTHORIZED_KEYS="$HOME/.ssh/authorized_keys"

# This script checks if the SSH keys in the authorized_keys file match those from a GitHub user.
check_ssh() {
  /bin/mkdir -p "$HOME/.ssh"
  /bin/chmod 700 "$HOME/.ssh"

  git_keys=$(/usr/bin/curl -s "https://github.com/$GITHUB_USER.keys")
  if [ -z "$git_keys" ]; then
    echo "$(date): No keys found or failed to fetch keys for $GITHUB_USER" >> "$HOME/ssh_key_update.log"
    return 1
  fi

  if [ -f "$AUTHORIZED_KEYS" ]; then
    local_keys=$(/bin/cat "$AUTHORIZED_KEYS")
  else
    local_keys=""
  fi

  if [[ "$git_keys" == "$local_keys" ]]; then
    echo "$(date): SSH keys are up to date." >> "$HOME/ssh_key_update.log"
  else
    echo "$git_keys" > "$AUTHORIZED_KEYS"
    /bin/chmod 600 "$AUTHORIZED_KEYS"
    echo "$(date): SSH keys updated." >> "$HOME/ssh_key_update.log"
  fi
}

check_ssh
