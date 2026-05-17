# LinuxSetup

Personal Linux workstation setup for terminal, shell, and editor configuration.

This repository currently manages:

- Kitty terminal configuration
- Neovim configuration built around `lazy.nvim`
- Zsh configuration, aliases, helper scripts, and plugin loading
- A root `install.sh` bootstrap script for installing packages and linking the configs into a user account

## Repository Layout

```text
.
|-- install.sh          # Main Linux installer/bootstrap script
|-- kitty/              # Kitty terminal config and appearance files
|-- nvim/               # Neovim config, plugins, keymaps, snippets, and help
`-- zsh/                # Zsh config, aliases, plugin config, themes, and helper scripts
```

## What The Installer Does

Run from the repository root:

```bash
./install.sh
```

The installer re-runs itself with `sudo` when needed, detects the original user, and installs core packages with one of these package managers:

- `apt`
- `dnf`
- `pacman`

It installs or attempts to install:

- Kitty
- Neovim
- Zsh
- build tools
- `curl`
- ShellCheck
- LuaRocks
- `luacheck` through LuaRocks

It then links the repo configs into the target user account:

- `kitty/` to `~/.config/kitty`
- `nvim/` to `~/.config/nvim`
- `zsh/zshrc` to `~/.zshrc`
- `zsh/bin` to `~/.local/bin`

Where supported, it also:

- sets Kitty as the default terminal through `update-alternatives`
- tries to set Kitty as the GNOME terminal app with `gsettings`
- changes the user shell to Zsh with `chsh`

After installation, log out and back in so shell changes take effect.

## Important Current Assumption

The Zsh config currently expects this repo to be available at:

```text
~/.LinuxSetup
```

For example, `zsh/zshrc` sets:

```zsh
ZSH_ROOT="$HOME/.LinuxSetup/zsh"
```

Until `install.sh` is improved, clone or link the repo there before relying on the Zsh config:

```bash
ln -s "$(pwd)" "$HOME/.LinuxSetup"
```

## Kitty

Kitty configuration lives in `kitty/`.

Main file:

- `kitty/kitty.conf`

Appearance files:

- `kitty/appearance/fonts.conf`
- `kitty/appearance/tab.conf`
- `kitty/appearance/artemis.conf`
- optional themes such as `gow.conf` and `hyper.conf`

The Kitty README includes a shortcut reference:

```bash
cat kitty/README.md
```

Once installed, the `khelp` helper prints that same reference from `~/.config/kitty/README.md`.

## Neovim

Neovim configuration lives in `nvim/`.

Main file:

- `nvim/init.lua`

Plugin management:

- bootstraps `lazy.nvim`
- loads plugin specs from `nvim/lua/plugins.lua`

Included plugin areas:

- Treesitter
- Telescope
- nvim-tree
- nvim-autopairs
- LuaSnip snippets
- nvim-lint
- GitHub Copilot
- CopilotChat
- ToggleTerm
- render-markdown
- Gruvbox
- Lualine

Useful command inside Neovim:

```vim
:MyHelp
```

That opens the Neovim README/keybinding reference.

## Zsh

Zsh configuration lives in `zsh/`.

Main file:

- `zsh/zshrc`

Core files:

- `zsh/core/prompt.zsh`
- `zsh/core/aliases.zsh`
- `zsh/core/plugins.zsh`

Plugin list:

- `zsh/plugins.txt`

Configured plugins:

- `zsh-autosuggestions`
- `zsh-syntax-highlighting`

Helper scripts in `zsh/bin/` include:

- `gpush` - add, commit, and push the current non-main branch
- `installIso` - write an ISO to a USB device with `dd`
- `checkos` - compare a file's SHA256 checksum
- `khelp` - print the Kitty shortcut README
- `uplugins` - clone/update Zsh plugins from `plugins.txt`
- `bandit` - helper for OverTheWire Bandit SSH levels
- `docker-up` and `docker-d` - remote docker-compose helpers
- `sshcmd` - run a command in a configured remote directory
- `update_ssh` - sync `authorized_keys` from a GitHub user's public keys
- `katmode` - toggle a configured touchscreen device with `xinput`

Some helper scripts contain machine-specific values such as remote host names, device IDs, usernames, or paths. Review them before running on another machine.

## Recommended Next Improvements

See [docs/installer.md](docs/installer.md) for installer notes and [docs/issues.md](docs/issues.md) for the active improvement issue list.

Highest priority:

- make `install.sh` create or validate the `~/.LinuxSetup` repo symlink
- stop deleting existing config directories without backup
- install all command dependencies used by helper scripts and Neovim plugins
- add idempotent package/plugin installation
- add a dry-run mode and clearer install output

## Safety Notes

- `install.sh` removes existing target config paths before linking new ones.
- `installIso` writes directly to block devices and can erase drives.
- `update_ssh` overwrites `~/.ssh/authorized_keys` with keys fetched from GitHub.
- `bandit` contains saved training-game passwords.

Review scripts before running them on a fresh system.
