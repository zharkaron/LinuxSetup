# Installer

`install.sh` bootstraps this repository on a Linux workstation.

## Supported Package Managers

The installer currently supports:

- `apt`
- `dnf`
- `pacman`

The package list is distro-specific because package names vary between distributions.

## Essentials Installed

The installer now attempts to install these groups of tools:

- terminal and shell: Kitty, Zsh
- editor: Neovim
- development basics: Git, Curl, compiler/build tools
- shell checks: ShellCheck
- Lua tooling: LuaRocks and `luacheck`
- helper-script dependencies: `sshpass`, `xinput`, Docker/Compose where available
- Neovim search/provider tools: Ripgrep, fd, Node.js, npm, Python, pip
- clipboard tools: `wl-clipboard`, `xclip`

Some package names may not exist on every distro release. The installer tries each package individually and prints a summary of installed, failed, and skipped items at the end.

## Config Links

The installer links:

- `kitty/` to `~/.config/kitty`
- `nvim/` to `~/.config/nvim`
- `zsh/zshrc` to `~/.zshrc`
- `zsh/bin` to `~/.local/bin`

## Known Follow-Up Work

Issue #98 focuses on essentials installation and is mostly handled by the current installer changes.

Remaining installer work is tracked separately:

- make config linking non-destructive
- add `--dry-run`, `--force`, and skip flags
- fix the `~/.LinuxSetup` path assumption used by Zsh
- automatically clone/update Zsh plugins

