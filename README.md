# Install customizations

```
sudo apt update
sudo apt remove nodejs -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y fish nodejs npm ninja-build gettext cmake unzip curl build-essential tar git shellcheck luarocks
sudo luarocks install luacheck
git clone git@github.com:Zh4rkaron/Linux-setup.git ~/.linux-setup
rm ~/.config/fish/config.fish
rm ~/.config/nvim/init.lua 
mkdir -p ~/.config/fish
mkdir -p ~/.config/nvim

ln -sf ~/.linux-setup/config.fish ~/.config/fish/config.fish
ln -sf ~/.linux-setup/init.lua ~/.config/nvim/init.lua 

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
chsh -s $(which fish)  # make zsh your default shell
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
