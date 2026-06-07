#!/usr/bin/env bash
set -Eeuo pipefail

# ---------------------------------------------
# Parse CLI flags
# ---------------------------------------------
DRY_RUN=false
FORCE=false
declare -a SKIP_SECTIONS=()
ORIGINAL_ARGS=("$@")

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --force) FORCE=true; shift ;;
        --skip-sections)
            shift
            IFS=',' read -ra SKIP_SECTIONS <<< "$1"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

set -- "${ORIGINAL_ARGS[@]}"

run() {
    if $DRY_RUN; then
        echo "[DRY-RUN] $*"
    else
        "$@"
    fi
}

section_is_skipped() {
    local section_name="$1"
    local s
    for s in "${SKIP_SECTIONS[@]}"; do
        [[ "$s" == "$section_name" ]] && return 0
    done
    return 1
}

# ---------------------------------------------
# Re-run as root if needed
# ---------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "Re-running installer as root..."
    exec sudo "$0" "${ORIGINAL_ARGS[@]}"
fi

# ---------------------------------------------
# Detect real user (not root)
# ---------------------------------------------
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=installer/packages.sh
source "$SETUP_DIR/installer/packages.sh"

INSTALLED_PACKAGES=()
FAILED_PACKAGES=()
SKIPPED_ITEMS=()
BACKED_UP_ITEMS=()
NEOVIM_CHANNEL="${NEOVIM_CHANNEL:-stable}"
KITTY_CHANNEL="${KITTY_CHANNEL:-stable}"
JDTLS_CHANNEL="${JDTLS_CHANNEL:-latest}"

echo "Installing for user: $TARGET_USER"
echo "Home directory: $TARGET_HOME"
echo "Repo directory: $SETUP_DIR"

# ---------------------------------------------
# Helpers
# ---------------------------------------------
install_package() {
    local package="$1"

    echo "Installing package: $package"
    if run "${PKG_INSTALL_CMD[@]}" "$package"; then
        INSTALLED_PACKAGES+=("$package")
    else
        echo "Warning: failed to install package: $package"
        FAILED_PACKAGES+=("$package")
    fi
}

install_optional_package() {
    local package="$1"
    local reason="$2"

    echo "Installing optional package: $package"
    if run "${PKG_INSTALL_CMD[@]}" "$package"; then
        INSTALLED_PACKAGES+=("$package")
    else
        echo "Warning: optional package unavailable: $package"
        SKIPPED_ITEMS+=("$package: $reason")
    fi
}

install_packages() {
    local package

    for package in "$@"; do
        install_package "$package"
    done
}

install_optional_packages() {
    local reason="$1"
    shift
    local package

    for package in "$@"; do
        install_optional_package "$package" "$reason"
    done
}

print_list() {
    local title="$1"
    shift
    local items=("$@")
    local item

    echo "$title"
    if ((${#items[@]} == 0)); then
        echo "  None"
        return
    fi

    for item in "${items[@]}"; do
        echo "  - $item"
    done
}

backup_existing() {
    local dest="$1"
    local src="$2"

    # Nothing exists at dest, caller should create symlink
    if [[ ! -e "$dest" && ! -L "$dest" ]]; then
        return 0
    fi

    # Already a symlink to the correct target, skip
    if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
        echo "  Already linked, skipping"
        return 1
    fi

    # Symlink pointing into this repo, safe to replace
    if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$SETUP_DIR"* ]]; then
        echo "  Replacing existing symlink to this repo"
        run rm -f "$dest"
        return 0
    fi

    # Otherwise, back it up
    local backup_path
    backup_path="${dest}.backup-$(date '+%Y%m%d-%H%M%S')"
    echo "  Backing up to $backup_path"
    run mv "$dest" "$backup_path"
    BACKED_UP_ITEMS+=("$backup_path")
    return 0
}

ensure_user_bin_dir() {
    local bin_dir="$TARGET_HOME/.local/bin"

    if [[ -L "$bin_dir" ]]; then
        echo "Replacing symlinked $bin_dir with a real directory"
        run rm -f "$bin_dir"
    fi

    run sudo -u "$TARGET_USER" mkdir -p "$bin_dir"
}

install_latest_neovim() {
    local arch
    local archive_name
    local download_url
    local tmp_archive
    local install_dir

    case "$(uname -m)" in
        x86_64|amd64)
            arch="x86_64"
            ;;
        aarch64|arm64)
            arch="arm64"
            ;;
        *)
            echo "Warning: unsupported Neovim binary architecture: $(uname -m)"
            SKIPPED_ITEMS+=("neovim upstream binary: unsupported architecture $(uname -m)")
            return
            ;;
    esac

    archive_name="nvim-linux-${arch}.tar.gz"
    install_dir="/opt/nvim-linux-${arch}"

    if [[ "$NEOVIM_CHANNEL" == "nightly" ]]; then
        download_url="https://github.com/neovim/neovim/releases/download/nightly/${archive_name}"
    else
        download_url="https://github.com/neovim/neovim/releases/latest/download/${archive_name}"
    fi

    tmp_archive="$(mktemp "/tmp/${archive_name}.XXXXXX")"

    echo "Installing latest Neovim from upstream: $download_url"
    if run curl -fsSL "$download_url" -o "$tmp_archive"; then
        run rm -rf "$install_dir"
        run tar -C /opt -xzf "$tmp_archive"
        run ln -sf "$install_dir/bin/nvim" /usr/local/bin/nvim
        INSTALLED_PACKAGES+=("neovim (${NEOVIM_CHANNEL} upstream)")
    else
        echo "Warning: failed to download upstream Neovim"
        FAILED_PACKAGES+=("neovim (${NEOVIM_CHANNEL} upstream)")
    fi

    run rm -f "$tmp_archive"
}

install_latest_kitty() {
    local installer
    local kitty_args
    local kitty_bin
    local kitten_bin

    installer="$(mktemp /tmp/kitty-installer.XXXXXX.sh)"
    kitty_args=(launch=n)

    if [[ "$KITTY_CHANNEL" == "nightly" ]]; then
        kitty_args=(installer=nightly launch=n)
    fi

    echo "Installing latest Kitty from upstream installer"
    if run curl -fsSL "https://sw.kovidgoyal.net/kitty/installer.sh" -o "$installer"; then
        run chmod 755 "$installer"
        run sudo -u "$TARGET_USER" HOME="$TARGET_HOME" sh "$installer" "${kitty_args[@]}"

        kitty_bin="$TARGET_HOME/.local/kitty.app/bin/kitty"
        kitten_bin="$TARGET_HOME/.local/kitty.app/bin/kitten"

        if [[ -x "$kitty_bin" ]]; then
            ensure_user_bin_dir
            run ln -sf "$kitty_bin" "$TARGET_HOME/.local/bin/kitty"
            run ln -sf "$kitten_bin" "$TARGET_HOME/.local/bin/kitten"
            run ln -sf "$kitty_bin" /usr/local/bin/kitty
            run ln -sf "$kitten_bin" /usr/local/bin/kitten
            run chown -h "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local/bin/kitty" "$TARGET_HOME/.local/bin/kitten"
            INSTALLED_PACKAGES+=("kitty (${KITTY_CHANNEL} upstream)")
        else
            echo "Warning: Kitty installer finished, but kitty binary was not found"
            FAILED_PACKAGES+=("kitty (${KITTY_CHANNEL} upstream)")
        fi
    else
        echo "Warning: failed to download upstream Kitty installer"
        FAILED_PACKAGES+=("kitty (${KITTY_CHANNEL} upstream)")
    fi

    run rm -f "$installer"
}

java_major_version() {
    local version_line
    local version
    local major

    version_line="$(java -version 2>&1 | head -n 1 || true)"
    version="$(printf '%s\n' "$version_line" | awk -F'"' '/version/ {print $2}' | head -n 1)"

    if [[ -z "$version" ]]; then
        echo "0"
        return
    fi

    if [[ "$version" == 1.* ]]; then
        major="${version#1.}"
        major="${major%%.*}"
    else
        major="${version%%.*}"
    fi

    printf '%s\n' "$major"
}

install_latest_jdtls() {
    local tmp_archive
    local tmp_extract
    local download_url
    local jdtls_script
    local jdtls_root
    local install_dir="/opt/jdtls"
    local config_dir="/usr/local/share/jdtls"
    local java_major

    if ! $FORCE && command -v jdtls >/dev/null 2>&1; then
        INSTALLED_PACKAGES+=("jdtls (already on PATH)")
        return
    fi

    java_major="$(java_major_version)"
    if [[ "$java_major" -lt 21 ]]; then
        echo "Warning: JDTLS requires Java 21 or newer, but java reports $java_major"
        FAILED_PACKAGES+=("jdtls (requires Java 21+)")
        return
    fi

    case "$JDTLS_CHANNEL" in
        latest|snapshot|snapshots)
            download_url="https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz"
            ;;
        milestone|milestones|stable)
            download_url="https://download.eclipse.org/jdtls/milestones/1.58.0/jdt-language-server-1.58.0-202604151538.tar.gz"
            ;;
        *)
            echo "Warning: unknown JDTLS_CHANNEL '$JDTLS_CHANNEL', using latest snapshot"
            download_url="https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz"
            ;;
    esac

    tmp_archive="$(mktemp "/tmp/jdtls.XXXXXX.tar.gz")"
    tmp_extract="$(mktemp -d "/tmp/jdtls.XXXXXX")"

    echo "Installing JDTLS from upstream: $download_url"
    if run curl -fsSL "$download_url" -o "$tmp_archive"; then
        run tar -C "$tmp_extract" -xzf "$tmp_archive"

        jdtls_script="$(find "$tmp_extract" -type f -path '*/bin/jdtls' -print -quit)"
        if [[ -z "$jdtls_script" ]]; then
            echo "Warning: JDTLS archive did not contain bin/jdtls"
            FAILED_PACKAGES+=("jdtls")
            run rm -rf "$tmp_archive" "$tmp_extract"
            return
        fi

        jdtls_root="$(dirname "$(dirname "$jdtls_script")")"
        run rm -rf "$install_dir"
        run mkdir -p "$install_dir"
        run cp -a "$jdtls_root"/. "$install_dir"/
        run mkdir -p "$config_dir"
        run ln -sf "$install_dir/bin/jdtls" /usr/local/bin/jdtls
        INSTALLED_PACKAGES+=("jdtls (${JDTLS_CHANNEL} upstream)")
    else
        echo "Warning: failed to download upstream JDTLS"
        FAILED_PACKAGES+=("jdtls (${JDTLS_CHANNEL} upstream)")
    fi

    run rm -rf "$tmp_archive" "$tmp_extract"
}

link_dir() {
    local src="$1"
    local dest="$2"

    echo "Linking $dest -> $src"
    backup_existing "$dest" "$src" || return 0
    run ln -s "$src" "$dest"
    run chown -h "$TARGET_USER:$TARGET_USER" "$dest"
}

link_file() {
    local src="$1"
    local dest="$2"

    echo "Linking $dest -> $src"
    backup_existing "$dest" "$src" || return 0
    run ln -s "$src" "$dest"
    run chown -h "$TARGET_USER:$TARGET_USER" "$dest"
}

link_bin_scripts() {
    local src_dir="$1"
    local dest_dir="$2"
    local script
    local dest

    ensure_user_bin_dir

    for script in "$src_dir"/*; do
        [[ -f "$script" ]] || continue
        dest="$dest_dir/$(basename "$script")"
        echo "Linking $dest -> $script"
        backup_existing "$dest" "$script" || continue
        run ln -s "$script" "$dest"
        run chown -h "$TARGET_USER:$TARGET_USER" "$dest"
    done
}

install_zsh_plugins() {
    local updater="$SETUP_DIR/zsh/bin/uplugins"

    if [[ ! -x "$updater" ]]; then
        echo "Warning: Zsh plugin updater is not executable: $updater"
        FAILED_PACKAGES+=("zsh plugins")
        return
    fi

    echo "Installing/updating Zsh plugins"
    if run sudo -u "$TARGET_USER" HOME="$TARGET_HOME" ZSH_ROOT="$SETUP_DIR/zsh" "$updater"; then
        INSTALLED_PACKAGES+=("zsh plugins")
    else
        echo "Warning: failed to install/update Zsh plugins"
        FAILED_PACKAGES+=("zsh plugins")
    fi
}

get_zsh_path() {
    if [[ -x /usr/bin/zsh ]]; then
        echo "/usr/bin/zsh"
    elif [[ -x /bin/zsh ]]; then
        echo "/bin/zsh"
    else
        command -v zsh
    fi
}

ensure_shell_is_allowed() {
    local shell_path="$1"

    if grep -qxF "$shell_path" /etc/shells; then
        return
    fi

    echo "Adding $shell_path to /etc/shells"
    if $DRY_RUN; then
        printf '%s\n' "[DRY-RUN] printf '%s\\n' '$shell_path' >> /etc/shells"
    else
        printf '%s\n' "$shell_path" >> /etc/shells
    fi
}

# ---------------------------------------------
# Distribution detection
# ---------------------------------------------

DETECTED_OS_ID=""
DETECTED_OS_ID_LIKE=""
DETECTED_OS_VERSION_ID=""
DETECTED_OS_PRETTY_NAME=""

detect_linux_distro() {
    if [[ ! -f /etc/os-release ]]; then
        return 1
    fi
    # shellcheck disable=SC1091
    source /etc/os-release
    DETECTED_OS_ID="${ID:-}"
    DETECTED_OS_ID_LIKE="${ID_LIKE:-}"
    DETECTED_OS_VERSION_ID="${VERSION_ID:-}"
    DETECTED_OS_PRETTY_NAME="${PRETTY_NAME:-}"
}

select_package_manager() {
    local os_id="${1,,}"
    local os_id_like="${2,,}"

    case "$os_id" in
        ubuntu|debian|linuxmint|pop|elementary|zorin|kali)
            PKG_MANAGER="apt"
            PKG_INSTALL_CMD=(apt install -y)
            return 0
            ;;
        fedora|rhel|centos|rocky|almalinux)
            PKG_MANAGER="dnf"
            PKG_INSTALL_CMD=(dnf install -y)
            return 0
            ;;
        arch|archlinux|endeavouros|manjaro|artix)
            PKG_MANAGER="pacman"
            PKG_INSTALL_CMD=(pacman -S --needed --noconfirm)
            return 0
            ;;
    esac

    # Fall back to ID_LIKE
    case ",${os_id_like}," in
        *,debian,*)
            PKG_MANAGER="apt"
            PKG_INSTALL_CMD=(apt install -y)
            return 0
            ;;
        *,fedora,*|*,rhel,*)
            PKG_MANAGER="dnf"
            PKG_INSTALL_CMD=(dnf install -y)
            return 0
            ;;
        *,arch,*)
            PKG_MANAGER="pacman"
            PKG_INSTALL_CMD=(pacman -S --needed --noconfirm)
            return 0
            ;;
    esac

    return 1
}

# ---------------------------------------------
# Section functions
# ---------------------------------------------

section_detect_distro() {
    detect_linux_distro

    if [[ -n "$DETECTED_OS_ID" ]]; then
        if select_package_manager "$DETECTED_OS_ID" "$DETECTED_OS_ID_LIKE"; then
            echo "Detected distribution: $DETECTED_OS_PRETTY_NAME"
            echo "Selected package manager: $PKG_MANAGER"
        else
            echo "Unsupported Linux distribution" >&2
            echo "  ID:          ${DETECTED_OS_ID:-unknown}" >&2
            echo "  ID_LIKE:     ${DETECTED_OS_ID_LIKE:-unknown}" >&2
            echo "  VERSION_ID:  ${DETECTED_OS_VERSION_ID:-unknown}" >&2
            echo "  PRETTY_NAME: ${DETECTED_OS_PRETTY_NAME:-unknown}" >&2
            echo >&2
            echo "This installer supports Ubuntu/Debian (apt), Fedora/RHEL (dnf), and Arch Linux (pacman) derivatives." >&2
            echo "To proceed anyway, open an issue at:" >&2
            echo "  https://github.com/zharkaron/LinuxSetup/issues" >&2
            exit 1
        fi
    else
        if command -v apt >/dev/null 2>&1; then
            PKG_MANAGER="apt"
            PKG_INSTALL_CMD=(apt install -y)
        elif command -v dnf >/dev/null 2>&1; then
            PKG_MANAGER="dnf"
            PKG_INSTALL_CMD=(dnf install -y)
        elif command -v pacman >/dev/null 2>&1; then
            PKG_MANAGER="pacman"
            PKG_INSTALL_CMD=(pacman -S --needed --noconfirm)
        else
            echo "No /etc/os-release found and no known package manager (apt/dnf/pacman) detected." >&2
            echo "Cannot determine how to install packages." >&2
            exit 1
        fi
        echo "Package manager detected by command availability: $PKG_MANAGER"
    fi
}

check_missing_commands() {
    local commands=("$@")
    local cmd pkg missing=()

    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            pkg="$(package_for_command "$cmd")"
            missing+=("$cmd")
            if [[ -n "$pkg" ]]; then
                echo "  $cmd → install package: $pkg"
            else
                echo "  $cmd → no package mapping found in manifest"
            fi
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        return 1
    fi
    return 0
}

section_packages() {
    echo ""
    echo ">>> Section: packages"

    load_package_manifest "$PKG_MANAGER"

    case "$PKG_MANAGER" in
        apt)   run apt update ;;
        pacman) run pacman -Sy ;;
    esac

    install_packages "${PKG_REQUIRED_PACKAGES[@]}"
    install_optional_packages "$PKG_OPTIONAL_REASON" "${PKG_OPTIONAL_PACKAGES[@]}"

    echo "Verifying required commands..."
    # Check only commands that are expected from distro packages (not upstream-installed like nvim, kitty)
    local check_commands=(
        zsh git curl tar shellcheck sshpass
        rg fd python3 pip3 node npm
        xclip xinput sha256sum awk ssh sudo dd sync
    )
    if ! check_missing_commands "${check_commands[@]}"; then
        echo ""
        echo "Some required commands are still missing after package installation."
        echo "You may need to enable additional repositories or install them manually."
    fi
}

section_neovim() {
    echo ""
    echo ">>> Section: neovim"
    install_latest_neovim
}

section_kitty() {
    echo ""
    echo ">>> Section: kitty"
    install_latest_kitty
}

section_jdtls() {
    echo ""
    echo ">>> Section: jdtls"
    install_latest_jdtls
}

section_configs() {
    echo ""
    echo ">>> Section: configs"

    run sudo -u "$TARGET_USER" mkdir -p "$TARGET_HOME/.config"
    run sudo -u "$TARGET_USER" mkdir -p "$TARGET_HOME/.local/bin"

    link_dir "$SETUP_DIR/kitty" "$TARGET_HOME/.config/kitty"
    link_dir "$SETUP_DIR/qutebrowser" "$TARGET_HOME/.config/qutebrowser"
    link_dir "$SETUP_DIR/nvim" "$TARGET_HOME/.config/nvim"
    link_dir "$SETUP_DIR/neomutt" "$TARGET_HOME/.config/neomutt"

    if command -v luarocks >/dev/null 2>&1; then
        if run luarocks install luacheck; then
            INSTALLED_PACKAGES+=("luacheck")
        else
            echo "Warning: failed to install luacheck with luarocks"
            FAILED_PACKAGES+=("luacheck")
        fi
    else
        SKIPPED_ITEMS+=("luacheck: luarocks is not installed")
    fi
}

section_zsh() {
    echo ""
    echo ">>> Section: zsh"

    link_file "$SETUP_DIR/zsh/zshrc" "$TARGET_HOME/.zshrc"
    link_bin_scripts "$SETUP_DIR/zsh/bin" "$TARGET_HOME/.local/bin"
    install_zsh_plugins
}

section_terminal() {
    echo ""
    echo ">>> Section: terminal"

    if command -v update-alternatives >/dev/null 2>&1; then
        run update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/kitty 50
        run update-alternatives --set x-terminal-emulator /usr/local/bin/kitty
    fi

    if command -v gsettings >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" && -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
        run sudo -u "$TARGET_USER" gsettings set \
            org.gnome.desktop.default-applications.terminal exec kitty || true
    else
        SKIPPED_ITEMS+=("GNOME terminal default: no graphical D-Bus session")
    fi
}

section_shell() {
    echo ""
    echo ">>> Section: shell"

    if command -v zsh >/dev/null 2>&1; then
        ZSH_PATH="$(get_zsh_path)"
        ensure_shell_is_allowed "$ZSH_PATH"
        run chsh -s "$ZSH_PATH" "$TARGET_USER"
    fi
}

# ---------------------------------------------
# Run sections
# ---------------------------------------------
section_detect_distro

section_is_skipped "packages" || section_packages
section_is_skipped "neovim"   || section_neovim
section_is_skipped "kitty"    || section_kitty
section_is_skipped "jdtls"    || section_jdtls
section_is_skipped "configs"  || section_configs
section_is_skipped "zsh"      || section_zsh
section_is_skipped "terminal" || section_terminal
section_is_skipped "shell"    || section_shell

echo
echo "Installation summary"
echo "Distribution: ${DETECTED_OS_PRETTY_NAME:-detected by command availability}"
echo "Package manager: $PKG_MANAGER"
print_list "Installed or already present:" "${INSTALLED_PACKAGES[@]}"
print_list "Failed or unavailable:" "${FAILED_PACKAGES[@]}"
print_list "Skipped:" "${SKIPPED_ITEMS[@]}"
print_list "Backed up:" "${BACKED_UP_ITEMS[@]}"
echo
echo "Installation complete."
echo "Log out and log back in to finish shell & terminal changes."
