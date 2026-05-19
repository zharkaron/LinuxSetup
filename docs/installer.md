# Installer

`install.sh` bootstraps this repository on a Linux workstation.

## Supported Package Managers

The installer currently supports:

- `apt`
- `dnf`
- `pacman`

The package list is distro-specific because package names vary between distributions.

## Latest App Installs

Neovim and Kitty are installed from their upstream release channels instead of from distro packages. This avoids old distro versions, especially on Debian/Ubuntu-based systems.

- Neovim stable: downloads the latest `nvim-linux-*.tar.gz` release from GitHub and links `nvim` into `/usr/local/bin`.
- Kitty stable: runs the official Kitty installer for the target user and links `kitty` and `kitten` into both `~/.local/bin` and `/usr/local/bin`.
- Zsh: installed from the configured distro repositories. This gives the newest Zsh version available to the system package manager.

Optional environment variables:

```bash
NEOVIM_CHANNEL=nightly ./install.sh
KITTY_CHANNEL=nightly ./install.sh
NEOVIM_CHANNEL=nightly KITTY_CHANNEL=nightly ./install.sh
```

## Essentials Installed

The installer now attempts to install these groups of tools:

- terminal and shell: latest upstream Kitty, distro Zsh
- editor: latest upstream Neovim
- development basics: Git, Curl, compiler/build tools
- shell checks: ShellCheck
- Lua tooling: LuaRocks and `luacheck`
- helper-script dependencies: `sshpass`, `xinput`, Docker/Compose where available
- Neovim search/provider tools: Ripgrep, fd, Node.js, npm, Python, pip
- clipboard tools: `wl-clipboard`, `xclip`

Some package names may not exist on every distro release. The installer tries each package individually and prints a summary of installed, failed, and skipped items at the end. Docker and Compose packages are treated as optional because their names and availability depend heavily on enabled repositories.

## Config Links

The installer links:

- `kitty/` to `~/.config/kitty`
- `nvim/` to `~/.config/nvim`
- `zsh/zshrc` to `~/.zshrc`

Helper scripts from `zsh/bin` are linked into `~/.local/bin` one file at a time. The installer does not replace a real `~/.local/bin` directory. If an older installer run left `~/.local/bin` as a symlink, the installer repairs it back into a real directory.

Zsh plugins listed in `zsh/plugins.txt` are cloned or updated into `zsh/plugins` automatically by `zsh/bin/uplugins`. The same helper can be run manually later to refresh plugins.

## Graphical Session Behavior

When run over SSH or another non-graphical session, the installer skips GNOME `gsettings` terminal-default changes because D-Bus is not available. This is expected and will appear in the skipped summary.

## Shell Change

Before running `chsh`, the installer ensures the selected Zsh path is listed in `/etc/shells`. This avoids warnings such as `/usr/sbin/zsh is not listed in /etc/shells`.

## Known Follow-Up Work

Issue #98 focuses on essentials installation and is mostly handled by the current installer changes.

Remaining installer work is tracked separately:

- make config linking non-destructive
- add `--dry-run`, `--force`, and skip flags
- fix the `~/.LinuxSetup` path assumption used by Zsh
