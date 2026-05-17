# GitHub Issue Backlog

These are issue-ready improvements for this repository. They are written so they can be copied into GitHub issues or created with `gh issue create`.

## 1. Make `install.sh` install a complete essentials setup

Labels: `enhancement`, `installer`

`install.sh` should install everything needed for this dotfiles setup to work after a fresh Linux install.

Acceptance criteria:

- Install packages used directly by this repo: `kitty`, `neovim`, `zsh`, `git`, `curl`, `shellcheck`, `luarocks`, build tools, and `luacheck`.
- Install packages needed by helper scripts where available: `sshpass`, `xinput`, `docker`/`docker-compose` or document that they are optional.
- Install common Neovim provider/tool dependencies where appropriate: `ripgrep`, `fd`, `nodejs`, `npm`, `python3`, `python3-pip`, and clipboard tools such as `xclip` or `wl-clipboard`.
- Use distro-specific package names for `apt`, `dnf`, and `pacman`.
- Print a clear summary of what was installed, skipped, or unavailable.

## 2. Fix the Zsh repo path mismatch

Labels: `bug`, `installer`, `zsh`

The Zsh config expects the repo at `~/.LinuxSetup`, but `install.sh` does not create that path.

Acceptance criteria:

- During install, create `~/.LinuxSetup` as a symlink to the cloned repository, or change Zsh config to use the installed config path.
- Ensure `ZSH_ROOT` resolves correctly after a fresh install.
- Ensure `zsh/core/plugins.zsh`, `zsh/themes/ArtemisBig.png`, and `zsh/bin` are found from a new login shell.
- Add a validation step that exits with a useful message if the expected path cannot be created.

## 3. Make the installer non-destructive by default

Labels: `bug`, `safety`, `installer`

The current `link_dir` and `link_file` helpers remove existing paths before creating symlinks. This can delete an existing config without backup.

Acceptance criteria:

- Back up existing files/directories before replacing them.
- Use timestamped backup names such as `~/.config/nvim.backup-YYYYMMDD-HHMMSS`.
- Do not remove existing files unless they are already symlinks pointing to this repo.
- Print each backup path in the install summary.

## 4. Add installer flags for dry-run, force, and skip sections

Labels: `enhancement`, `installer`

Add CLI flags so the installer can be previewed and partially run.

Acceptance criteria:

- `--dry-run` prints intended package installs, links, shell changes, and terminal changes without modifying the system.
- `--force` allows replacing existing files after backup.
- `--skip-packages`, `--skip-kitty`, `--skip-nvim`, `--skip-zsh`, and `--skip-shell-change` are supported.
- `./install.sh --help` documents all options.

## 5. Install and update Zsh plugins automatically

Labels: `enhancement`, `zsh`, `installer`

Zsh plugin URLs live in `zsh/plugins.txt`, but the installer does not currently clone them.

Acceptance criteria:

- Ensure `zsh/plugins.txt` is used consistently.
- Clone or update each plugin during install.
- Use one plugin directory path consistently across `zshrc`, `plugins.zsh`, and `uplugins`.
- Handle missing `git` with a clear error.

## 6. Add basic validation and lint checks

Labels: `quality`, `ci`

Add local checks so installer and config regressions are easier to catch.

Acceptance criteria:

- Add a script or Makefile target for checking shell scripts with ShellCheck.
- Add Lua formatting/linting guidance or checks for Neovim Lua files.
- Validate that expected config files exist.
- Add a GitHub Actions workflow that runs the checks on pull requests.

## 7. Review machine-specific helper scripts

Labels: `maintenance`, `zsh`

Several scripts contain machine-specific values that should be configurable or documented.

Acceptance criteria:

- Move hard-coded remote hosts, remote paths, usernames, and device IDs into environment variables or config files.
- Add usage text to each helper script.
- Make scripts fail clearly when required commands or config values are missing.
- Document which scripts are personal-only and which are generally reusable.
