#!/bin/bash

echo "Linking zsh config..."
ln -sf "$PWD/zsh/.zshrc" ~/.zshrc
ln -sf "$PWD/zsh/.p10k.zsh" ~/.p10k.zsh

echo "Linking Neovim config..."
mkdir -p ~/.config/nvim
ln -sf "$PWD/nvim/init.lua" ~/.config/nvim/init.lua

echo "Installing Oh My Zsh if missing..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Done! Run 'zsh' or restart your terminal."
