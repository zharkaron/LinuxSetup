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
