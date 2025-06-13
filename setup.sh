#!/bin/bash

install_package() {
    PACKAGE=$1

    if command -v apt-get >/dev/null 2>&1; then
        echo "Detected apt package manager (Debian/Ubuntu). Installing $PACKAGE..."
        sudo apt-get update
        sudo apt-get install -y "$PACKAGE"
    elif command -v pacman >/dev/null 2>&1; then
        echo "Detected pacman package manager (Arch). Installing $PACKAGE..."
        sudo pacman -Sy --noconfirm "$PACKAGE"
    else
        echo "Unsupported package manager. Please install $PACKAGE manually."
        exit 1
    fi
}

check_and_install() {
    CMD=$1          # command to check, e.g. 'zsh'
    PKG=$2          # package name to install, e.g. 'zsh'
    DISPLAY_NAME=$3 # friendly name to show in messages

    if command -v "$CMD" >/dev/null 2>&1; then
        echo "✅ $DISPLAY_NAME is already installed."
    else
        echo "❌ $DISPLAY_NAME is not installed. Installing now..."
        install_package "$PKG"
    fi
}

create_symlinks() {
    echo "🔗 Creating symlinks for terminal setup..."

    BASE_DIR="$HOME/.linux-setup"

    ln -sf "$BASE_DIR/.zshrc" "$HOME/.zshrc"
    echo "✔️ Linked .zshrc"

    ln -sf "$BASE_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    echo "✔️ Linked .p10k.zsh"

    ln -sf "$BASE_DIR/oh-my-zsh" "$HOME/.oh-my-zsh"
    echo "✔️ Linked .oh-my-zsh"

    mkdir -p "$HOME/.config/nvim"
    ln -sf "$BASE_DIR/init.lua" "$HOME/.config/nvim/init.lua"
    echo "✔️ Linked Neovim init.lua"

    echo "✅ All symlinks created!"
}

# Run checks and installation for each tool
check_and_install zsh zsh "Zsh"
check_and_install nvim neovim "Neovim"
create_symlinks
