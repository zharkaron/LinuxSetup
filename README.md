# Install customizations


```
git clone git@github.com:Zh4rkaron/Linux-setup.git ~/.linux-setup

rm ~/.p10k.zsh
rm ~/.zshrc
rm ~/.config/nvim/init.lua 

mkdir -p ~/.config/nvim/init.lua

ln -sf ~/.linux-setup/p10k.zsh ~/.p10k.zsh
ln -sf ~/.linux-setup/zshrc ~/.zshrc
ln -sf ~/.linux-setup/init.lua ~/.config/nvim/init.lua 

```
