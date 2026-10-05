# Installer

`install.sh` bootstraps this repository on a Linux workstation.

## Supported Package Managers

The installer currently supports:

- `apt`
- `dnf`
- `pacman`

The package list is distro-specific because package names vary between distributions. Package and command mappings live in `installer/packages.sh`, which keeps distro-specific package names separate from the install flow.

## Package Manifest

`installer/packages.sh` defines:

- required packages for each supported package manager
- optional packages, currently Docker/Compose related
- command-to-package mappings, such as `rg` to `ripgrep`, `fd` to `fd-find` or `fd`, and Java tools like `java`, `javac`, `mvn`, and `gradle`

The manifest is meant to support future installer preflight checks and an interactive Zsh command-not-found prompt.

Java LSP is also installed automatically now: `install.sh` downloads the upstream `jdtls` wrapper, places it under `/opt/jdtls`, and links `jdtls` into `/usr/local/bin`.

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
- development basics: Git, Curl, compiler/build tools, `unzip`
- shell checks: ShellCheck
- Lua tooling: LuaRocks and `luacheck`
- helper-script dependencies: `sshpass`, `xinput`, Docker/Compose where available
- Neovim search/provider tools: Ripgrep, fd, Node.js, npm, Python, pip
- clipboard tools: `wl-clipboard`, `xclip`
- document conversion: Pandoc (`pandoc` on apt/pacman, `pandoc-cli` on dnf)
- terminal fonts: the Powerline symbols package plus a per-user FiraCode Nerd Font
- Java: a JDK, so the JDTLS section can actually run

## Sections

The installer runs in sections, and any of them can be skipped:

| Section | What it does |
| --- | --- |
| `packages` | distro packages from `installer/packages.sh` |
| `fonts` | per-user FiraCode Nerd Font + `fc-cache` |
| `neovim` | upstream Neovim into `/opt`, linked into `/usr/local/bin` |
| `kitty` | upstream Kitty via the official installer |
| `jdtls` | Eclipse JDTLS into `/opt/jdtls`, linked into `/usr/local/bin` |
| `bitwarden` | Bitwarden CLI into `/opt/bw-cli`, linked into `/usr/local/bin` |
| `configs` | config symlinks, `luacheck`, global git hooks |
| `zsh` | `.zshrc`, helper scripts, Zsh plugins |
| `terminal` | default terminal via `update-alternatives` and the desktop |
| `shell` | `chsh` to Zsh |

Example:

```bash
./install.sh --skip-sections packages,terminal
```

## Permissions Notes

Two upstream archives extract into directories that `mktemp -d` created as
`0700` and root-owned. Copying them with `cp -a src/. dest/` also copies that
mode onto the destination, which would leave `/opt/jdtls` untraversable and the
`jdtls` link unusable. The installer chmods those destinations explicitly after
copying.

When the installer re-runs itself through `sudo`, `sudo`'s `env_reset` drops
`DISPLAY`, `WAYLAND_DISPLAY`, and `DBUS_SESSION_BUS_ADDRESS`. Those variables are
passed through explicitly, otherwise the desktop integration steps would always
report "no graphical D-Bus session" and silently skip.

Some package names may not exist on every distro release. The installer tries each package individually and prints a summary of installed, failed, and skipped items at the end. Docker and Compose packages are treated as optional because their names and availability depend heavily on enabled repositories.

## Config Links

The installer links:

- `kitty/` to `~/.config/kitty`
- `nvim/` to `~/.config/nvim`
- `zsh/zshrc` to `~/.zshrc`

Helper scripts from `zsh/bin` are linked into `~/.local/bin` one file at a time. The installer does not replace a real `~/.local/bin` directory. If an older installer run left `~/.local/bin` as a symlink, the installer repairs it back into a real directory.

Zsh plugins listed in `zsh/plugins.txt` are cloned or updated into `zsh/plugins` automatically by `zsh/bin/uplugins`. The same helper can be run manually later to refresh plugins.

## Graphical Session Behavior

When run over SSH or another non-graphical session, the installer skips the desktop terminal-default change because D-Bus is not available. This is expected and will appear in the skipped summary.

On KDE Plasma the default terminal is written to `kdeglobals` with
`kwriteconfig6`/`kwriteconfig5`, because KDE does not read the GNOME
`org.gnome.desktop.default-applications.terminal` key. The `gsettings` path is
kept as the GNOME fallback.

## Shell Change

Before running `chsh`, the installer ensures the selected Zsh path is listed in `/etc/shells`. This avoids warnings such as `/usr/sbin/zsh is not listed in /etc/shells`.

## Known Follow-Up Work

Issue #98 focuses on essentials installation and is mostly handled by the current installer changes.

Resolved:

- make config linking non-destructive (existing paths are backed up, not deleted)
- add `--dry-run`, `--force`, and skip flags
- fix the `~/.LinuxSetup` path assumption used by Zsh ✓ (resolved by dynamic ZSH_ROOT resolution in zshrc)
- install a JDK so the JDTLS section can run instead of always failing on a missing `java`
- use distro-correct Pandoc package names so `pandoc` verification passes

Remaining installer work is tracked separately:

- add automated coverage for package-name drift between distro releases
