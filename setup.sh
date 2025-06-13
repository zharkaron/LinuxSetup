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

check_and_install_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        echo "✅ Zsh is already installed."
    else
        echo "❌ Zsh is not installed. Installing now..."
        install_package zsh
    fi
}

check_and_install_nvim() {
    if command -v nvim >/dev/null 2>&1; then
        echo "✅ Neovim is already installed."
    else
        echo "❌ Neovim is not installed. Installing now..."
        install_package neovim
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

# Run checks and installation
check_and_install_zsh
check_and_install_nvim
create_symlinks
