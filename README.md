# Install customizations

```
sudo apt update
sudo apt remove nodejs -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y zsh nodejs npm ninja-build gettext cmake unzip curl build-essential tar git
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
git clone https://github.com/neovim/neovim.git
cd neovim

git checkout stable

make CMAKE_BUILD_TYPE=Release
sudo make install
```

# Authenticate to CopilotChat to use
```
:Copilot auth
```

#  set zsh as your terminal best if you reboot
```
chsh -s $(which zsh)  # make zsh your default shell
source ~/.zshrc        # apply settings without logging out
```
# Fringerprint set up if it dosent work
```
$ sudo apt remove fprintd
$ sudo add-apt-repository ppa:uunicorn/open-fprintd
$ sudo apt-get update
$ sudo apt install open-fprintd fprintd-clients python3-validity
...wait a bit...
$ fprintd-enroll
```
