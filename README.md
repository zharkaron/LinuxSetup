# Install customizations

```
sudo apt update
sudo apt install zsh
git clone git@github.com:Zh4rkaron/Linux-setup.git ~/.linux-setup
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.linux-setup/oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.linux-setup/oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.linux-setup/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.linux-setup/oh-my-zsh/custom/themes/powerlevel10k

rm ~/.p10k.zsh
rm ~/.zshrc
rm ~/.config/nvim/init.lua 

mkdir -p ~/.config/nvim

ln -sf ~/.linux-setup/p10k.zsh ~/.p10k.zsh
ln -sf ~/.linux-setup/zshrc ~/.zshrc
ln -sf ~/.linux-setup/init.lua ~/.config/nvim/init.lua 
ln -sf ~/.linux-setup/oh-my-zsh ~/.oh-my-zsh
```
# Install neovim

```
sudo apt update
sudo apt install -y ninja-build gettext cmake unzip curl build-essential tar git

git clone https://github.com/neovim/neovim.git
cd neovim

git checkout stable

make CMAKE_BUILD_TYPE=Release
sudo make install
```
#  set zsh as your terminal best if you reboot
```
chsh -s $(which zsh)  # make zsh your default shell
source ~/.zshrc        # apply settings without logging out
```
