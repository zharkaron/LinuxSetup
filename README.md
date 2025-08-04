# Setup zshrc
```
sudo dnf/apt install zsh
ln -sf ~/.LinuxSetup/zshrc ~/.zshrc
sudo dnf/apt install zsh-syntax-highlighting
sudo dnf/apt install zsh-autosuggestions
```

# Setup kitty terminal
```
sudo dnf/apt install kitty
ln -sf ~/.LinuxSetup/kitty.conf ~/.config/kitty/kitty.conf
```

# Install neovim

```
git clone https://github.com/neovim/neovim.git
cd neovim

apt-get install make cmake -y

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
