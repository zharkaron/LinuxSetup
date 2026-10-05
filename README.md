# LinuxSetup

Personal Linux workstation setup for terminal, shell, and editor configuration.

This repository currently manages:

- Kitty terminal configuration
- Neovim configuration built around `lazy.nvim`
- NeoMutt email client configuration with optional helper tooling
- Zsh configuration, aliases, helper scripts, and plugin loading
- A root `install.sh` bootstrap script for installing packages and linking the configs into a user account

## Repository Layout

```text
.
|-- install.sh          # Main Linux installer/bootstrap script
|-- installer/          # Distro-aware package manifest sourced by install.sh
|-- kitty/              # Kitty terminal config and appearance files
|-- neomutt/            # NeoMutt mail client config and account templates
|-- nvim/               # Neovim config, plugins, keymaps, snippets, and help
|-- qutebrowser/        # qutebrowser config and theme
|-- git-hooks/          # Git hooks installed globally via core.hooksPath
|-- docs/               # Installer notes and the active issue list
`-- zsh/                # Zsh config, aliases, plugin config, themes, and helper scripts
```

## Installation

Run from the repository root:

```bash
./install.sh --dry-run   # preview everything, no root needed
./install.sh             # install packages, tools, and config links
```

Flags:

- `--dry-run` prints every action without changing the system. It stays
  unprivileged, so it never asks for a password.
- `--force` reinstalls components that are already present.
- `--skip-sections a,b,c` skips the named sections. Valid sections are
  `packages`, `fonts`, `neovim`, `kitty`, `jdtls`, `bitwarden`, `configs`,
  `zsh`, `terminal`, and `shell`.

The installer symlinks configs to absolute paths inside this repository, so
clone it somewhere permanent such as `~/LinuxSetup` before running it.

Re-running is safe: existing links are left alone, and upstream components are
skipped when they are already installed unless `--force` is passed.

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

- latest upstream Kitty
- latest upstream Neovim
- Zsh
- build tools
- `curl`
- ShellCheck
- LuaRocks
- `luacheck` through LuaRocks

Neovim is installed from the official GitHub release archive and Kitty is installed with the official Kitty installer so they are not limited by older distro package repositories. Zsh is installed from the configured system package repositories.

It then links the repo configs into the target user account:

- `kitty/` to `~/.config/kitty`
- `qutebrowser/` to `~/.config/qutebrowser`
- `neomutt/` to `~/.config/neomutt`
- `nvim/` to `~/.config/nvim`
- `git-hooks/` to `~/.config/git-hooks`
- `zsh/zshrc` to `~/.zshrc`
- `zsh/bin` to `~/.local/bin`

Where supported, it also:

- installs the FiraCode Nerd Font per-user and the Powerline symbols system-wide, so Kitty and Neovim render their icons
- installs the Bitwarden CLI to `/opt/bw-cli`
- sets Kitty as the default terminal through `update-alternatives`
- sets Kitty as the desktop default terminal, using `kwriteconfig` on KDE Plasma and `gsettings` on GNOME
- points `git config --global core.hooksPath` at `git-hooks/`, which blocks pushes to `main` and `master`
- changes the user shell to Zsh with `chsh`

After installation, log out and back in so shell changes take effect.

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

- Treesitter, Treesitter textobjects, nvim-ts-autotag
- Telescope, telescope-ui-select
- nvim-tree, nvim-web-devicons
- nvim-autopairs, Comment.nvim
- LuaSnip snippets
- nvim-lint
- Flash
- Conform, Mason, mason-lspconfig, nvim-lspconfig
- CodeCompanion chat and minuet-ai inline completion, both against a local Ollama model
- ToggleTerm
- render-markdown
- nvim-cmp with cmp-nvim-lsp
- DAP, nvim-dap-ui, nvim-dap-virtual-text
- Gitsigns, Neogit, Harpoon, Undotree
- Bufferline, Noice, which-key, Todo Comments, Trouble, Aerial
- vim-illuminate, nvim-surround
- Artemis x Mint colorscheme (local, in `nvim/colors/artemis.lua`)
- Lualine

### Colours

Neovim and Kitty share one palette. The colours come from the Kitty theme
`kitty/appearance/artemis.conf`, and the same hex values are repeated in
`nvim/lua/nvim/palette.lua` so both render identically:

- background `#1e1f21`, foreground `#c7c7c7`
- cursor `#a1ff9e`, selection `#4b5668`
- red `#ff4f79`, green `#a1ff9e`, yellow `#f7ff6b`, blue `#9b5de5`,
  cyan `#6fffe9`, magenta `#88c0d0`

Files:

- `nvim/lua/nvim/palette.lua` — the palette. Change this and
  `kitty/appearance/artemis.conf` together.
- `nvim/colors/artemis.lua` — the colorscheme: editor UI, syntax, Treesitter
  captures, LSP semantic tokens, diff and diagnostics.
- `nvim/lua/nvim/style.lua` — applies the colorscheme and sets up Lualine.
  The Lualine theme copies the zsh prompt's colours, so the statusline shows the
  mode, git branch, a yellow path and a magenta branch just like the shell.

Per-plugin highlight groups live next to their existing config:

- `nvim/lua/telescope/style.lua`
- `nvim/lua/nvimtree/style.lua`
- `nvim/lua/gitsigns/style.lua`
- `nvim/lua/neogit/style.lua`
- `nvim/lua/bufferline/style.lua`
- `nvim/lua/noice/style.lua`

To change the colour scheme, edit `nvim/lua/nvim/palette.lua` and apply it
inside Neovim with `:colorscheme artemis`.

Font settings live only in `kitty/appearance/fonts.conf`. Do not add
`font_size` to a Kitty colour theme: `kitty.conf` includes `fonts.conf` first,
so a later `font_size` silently wins.

Useful command inside Neovim:

```vim
:MyHelp
```

That opens the Neovim README/keybinding reference.

## NeoMutt

NeoMutt configuration lives in `neomutt/`.

Main file:

- `neomutt/muttrc`

Supporting files:

- `neomutt/mailcap` — MIME type handlers for attachments

Account configs are placed in `neomutt/accounts/`, one `.muttrc` per account. These files are gitignored — you must create them yourself with your own credentials.

Local overrides (editor path, passwords, etc.) go in `neomutt/muttrc.local`, also gitignored.

The installer optionally installs these helper tools when available:

- `mbsync` / `isync` — IMAP → Maildir sync
- `msmtp` — SMTP client
- `notmuch` — full-text email search
- `pass` — password store

See `neomutt/README.md` for account templates and setup instructions.

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

## Local AI Setup

The Neovim chat panel and inline ghost-text completions both talk to a local
[Ollama](https://ollama.com) server on port 11434. They are configured for
`qwen2.5-coder:7b` by default.

```bash
# one-time: install the server (needs the NVIDIA driver for GPU acceleration)
curl -fsSL https://ollama.com/install.sh | sh

# fetch the model the config expects
ollama pull qwen2.5-coder:7b

# use a different model for both chat and inline completion
nvim -c ':SetModel qwen2.5-coder:14b'
```

Ollama does not need to be installed by `install.sh`, because it is a separate
service rather than a dotfiles dependency. `nvim/lua/nvim/ai/host.lua` probes
`127.0.0.1` first and falls back to WSL host candidates when applicable, so
neither host needs to be configured by hand.

## Checks

```bash
make check
```

This runs ShellCheck over the shell scripts, `luacheck` over the Lua config,
and verifies that all expected config files are present. `make lint-sh` and
`make lint-lua` run the individual linters.

## Recommended Next Improvements

See [docs/installer.md](docs/installer.md) for installer notes and [docs/issues.md](docs/issues.md) for the active improvement issue list.

Highest priority:

- add the Bitwarden CLI and Nerd Font steps to CI coverage notes
- cover Fedora and Arch package-name drift in tests
- document the NeoMutt account template workflow end to end

## Safety Notes

- `install.sh` backs up an existing config path to `<path>.backup-<timestamp>`
  before replacing it, rather than deleting it. Review `~/.config/*.backup-*`
  if a link looks wrong.
- The installer sets `git config --global core.hooksPath`, so the pre-push hook
  that blocks `main`/`master` applies to every repository on the machine.
- `installIso` writes directly to block devices and can erase drives.
- `update_ssh` overwrites `~/.ssh/authorized_keys` with keys fetched from GitHub.
- `bandit` contains saved training-game passwords.

Review scripts before running them on a fresh system.
