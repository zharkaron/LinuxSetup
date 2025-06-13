#!/bin/bash

install_package() {
  pkg=$1
  if command -v apt-get &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y "$pkg"
  elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm "$pkg"
  else
    echo "Unsupported package manager. Install $pkg manually."
    exit 1
  fi
}

check_and_install() {
  cmd=$1 pkg=$2 name=$3
  if ! command -v "$cmd" &>/dev/null; then
    echo "Installing $name..."
    install_package "$pkg"
  else
    echo "$name already installed."
  fi
}

safe_symlink() {
  target=$1 link=$2
  if [ -L "$link" ]; then
    [ "$(readlink "$link")" = "$target" ] && return || ln -sf "$target" "$link"
  elif [ -e "$link" ]; then
    mv "$link" "${link}.backup"
    ln -sf "$target" "$link"
  else
    ln -sf "$target" "$link"
  fi
}

create_symlinks() {
  base="$HOME/.linux-setup"
  safe_symlink "$base/.zshrc" "$HOME/.zshrc"
  safe_symlink "$base/.p10k.zsh" "$HOME/.p10k.zsh"
  safe_symlink "$base/oh-my-zsh" "$HOME/.oh-my-zsh"
  mkdir -p "$HOME/.config/nvim"
  safe_symlink "$base/init.lua" "$HOME/.config/nvim/init.lua"
}

update_config() {
  repo="$HOME/.linux-setup"
  cd "$repo" && git pull origin main
  create_symlinks
}

set_default_shell() {
  if [ "$SHELL" != "$(command -v zsh)" ]; then
    chsh -s "$(command -v zsh)" || echo "Failed to set zsh as default shell"
  fi
}

add_update_to_shellrc() {
  local line='[ -d "$HOME/.linux-setup" ] && ~/.linux-setup/setup-terminal.sh update'
  
  # For .zshrc
  if ! grep -Fxq "$line" "$HOME/.zshrc"; then
    echo "$line" >> "$HOME/.zshrc"
    echo "Added update command to .zshrc"
  fi
  
  # For .bashrc (optional)
  if [ -f "$HOME/.bashrc" ]; then
    if ! grep -Fxq "$line" "$HOME/.bashrc"; then
      echo "$line" >> "$HOME/.bashrc"
      echo "Added update command to .bashrc"
    fi
  fi
}

if [[ $1 == "install" ]]; then
  check_and_install zsh zsh "Zsh"
  check_and_install nvim neovim "Neovim"
  create_symlinks
  set_default_shell
  add_update_to_shellrc
fi

if [[ $1 == "update" ]]; then
  update_config
fi
