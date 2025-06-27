# Install customizations

```
sudo apt update
sudo apt install zsh
git clone git@github.com:Zh4rkaron/Linux-setup.git ~/.linux-setup
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

```
# Install neovim

```
# 1. Install dependencies
sudo apt update
sudo apt install -y ninja-build gettext cmake unzip curl build-essential tar git

# 2. Clone Neovim source
git clone https://github.com/neovim/neovim.git
cd neovim

# 3. Checkout latest stable release
git checkout stable  # or `git checkout v0.10.0`

# 4. Build and install
make CMAKE_BUILD_TYPE=Release
sudo make install
```
