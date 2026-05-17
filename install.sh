#!/usr/bin/env bash
set -Eeuo pipefail

# ---------------------------------------------
# Re-run as root if needed
# ---------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "Re-running installer as root..."
    exec sudo "$0" "$@"
fi

# ---------------------------------------------
# Detect real user (not root)
# ---------------------------------------------
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLED_PACKAGES=()
FAILED_PACKAGES=()
SKIPPED_ITEMS=()
NEOVIM_CHANNEL="${NEOVIM_CHANNEL:-stable}"
KITTY_CHANNEL="${KITTY_CHANNEL:-stable}"

echo "Installing for user: $TARGET_USER"
echo "Home directory: $TARGET_HOME"
echo "Repo directory: $SETUP_DIR"

# ---------------------------------------------
# Helpers
# ---------------------------------------------
install_package() {
    local package="$1"

    echo "Installing package: $package"
    if "${PKG_INSTALL_CMD[@]}" "$package"; then
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
    if "${PKG_INSTALL_CMD[@]}" "$package"; then
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

ensure_user_bin_dir() {
    local bin_dir="$TARGET_HOME/.local/bin"

    if [[ -L "$bin_dir" ]]; then
        echo "Replacing symlinked $bin_dir with a real directory"
        rm -f "$bin_dir"
    fi

    sudo -u "$TARGET_USER" mkdir -p "$bin_dir"
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
    if curl -fsSL "$download_url" -o "$tmp_archive"; then
        rm -rf "$install_dir"
        tar -C /opt -xzf "$tmp_archive"
        ln -sf "$install_dir/bin/nvim" /usr/local/bin/nvim
        INSTALLED_PACKAGES+=("neovim (${NEOVIM_CHANNEL} upstream)")
    else
        echo "Warning: failed to download upstream Neovim"
        FAILED_PACKAGES+=("neovim (${NEOVIM_CHANNEL} upstream)")
    fi

    rm -f "$tmp_archive"
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
    if curl -fsSL "https://sw.kovidgoyal.net/kitty/installer.sh" -o "$installer"; then
        chmod 755 "$installer"
        sudo -u "$TARGET_USER" HOME="$TARGET_HOME" sh "$installer" "${kitty_args[@]}"

        kitty_bin="$TARGET_HOME/.local/kitty.app/bin/kitty"
        kitten_bin="$TARGET_HOME/.local/kitty.app/bin/kitten"

        if [[ -x "$kitty_bin" ]]; then
            ensure_user_bin_dir
            ln -sf "$kitty_bin" "$TARGET_HOME/.local/bin/kitty"
            ln -sf "$kitten_bin" "$TARGET_HOME/.local/bin/kitten"
            ln -sf "$kitty_bin" /usr/local/bin/kitty
            ln -sf "$kitten_bin" /usr/local/bin/kitten
            chown -h "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local/bin/kitty" "$TARGET_HOME/.local/bin/kitten"
            INSTALLED_PACKAGES+=("kitty (${KITTY_CHANNEL} upstream)")
        else
            echo "Warning: Kitty installer finished, but kitty binary was not found"
            FAILED_PACKAGES+=("kitty (${KITTY_CHANNEL} upstream)")
        fi
    else
        echo "Warning: failed to download upstream Kitty installer"
        FAILED_PACKAGES+=("kitty (${KITTY_CHANNEL} upstream)")
    fi

    rm -f "$installer"
}

link_dir() {
    local src="$1"
    local dest="$2"

    echo "Linking $dest -> $src"
    rm -rf "$dest"
    ln -s "$src" "$dest"
    chown -h "$TARGET_USER:$TARGET_USER" "$dest"
}

link_file() {
    local src="$1"
    local dest="$2"

    echo "Linking $dest -> $src"
    rm -f "$dest"
    ln -s "$src" "$dest"
    chown -h "$TARGET_USER:$TARGET_USER" "$dest"
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
        ln -sf "$script" "$dest"
        chown -h "$TARGET_USER:$TARGET_USER" "$dest"
    done
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
    printf '%s\n' "$shell_path" >> /etc/shells
}

# ---------------------------------------------
# Package manager detection
# ---------------------------------------------
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    PKG_INSTALL_CMD=(apt install -y)
    apt update

    install_packages \
        zsh \
        git \
        curl \
        tar \
        shellcheck \
        luarocks \
        build-essential \
        sshpass \
        xinput \
        ripgrep \
        fd-find \
        nodejs \
        npm \
        python3 \
        python3-pip \
        wl-clipboard \
        xclip

    install_optional_packages "optional Docker/Compose support" \
        docker.io \
        docker-compose-plugin \
        docker-compose
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    PKG_INSTALL_CMD=(dnf install -y)

    install_packages \
        zsh \
        git \
        curl \
        tar \
        ShellCheck \
        luarocks \
        gcc \
        gcc-c++ \
        make \
        sshpass \
        xinput \
        ripgrep \
        fd-find \
        nodejs \
        npm \
        python3 \
        python3-pip \
        wl-clipboard \
        xclip

    install_optional_packages "optional Docker/Compose support; package availability depends on enabled repos" \
        docker \
        docker-compose-plugin \
        docker-compose
elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
    PKG_INSTALL_CMD=(pacman -S --needed --noconfirm)
    pacman -Sy

    install_packages \
        zsh \
        git \
        curl \
        tar \
        shellcheck \
        luarocks \
        base-devel \
        sshpass \
        xorg-xinput \
        ripgrep \
        fd \
        nodejs \
        npm \
        python \
        python-pip \
        wl-clipboard \
        xclip

    install_optional_packages "optional Docker/Compose support" \
        docker \
        docker-compose
else
    echo "Unsupported distro: no known package manager found."
    exit 1
fi

install_latest_neovim
install_latest_kitty

# ---------------------------------------------
# Create base directories
# ---------------------------------------------
sudo -u "$TARGET_USER" mkdir -p "$TARGET_HOME/.config"
sudo -u "$TARGET_USER" mkdir -p "$TARGET_HOME/.local/bin"

# ---------------------------------------------
# Kitty
# ---------------------------------------------
link_dir "$SETUP_DIR/kitty" "$TARGET_HOME/.config/kitty"

# ---------------------------------------------
# Neovim
# ---------------------------------------------
link_dir "$SETUP_DIR/nvim" "$TARGET_HOME/.config/nvim"

if command -v luarocks >/dev/null 2>&1; then
    if luarocks install luacheck; then
        INSTALLED_PACKAGES+=("luacheck")
    else
        echo "Warning: failed to install luacheck with luarocks"
        FAILED_PACKAGES+=("luacheck")
    fi
else
    SKIPPED_ITEMS+=("luacheck: luarocks is not installed")
fi

# ---------------------------------------------
# Zsh
# ---------------------------------------------
link_file "$SETUP_DIR/zsh/zshrc" "$TARGET_HOME/.zshrc"
link_bin_scripts "$SETUP_DIR/zsh/bin" "$TARGET_HOME/.local/bin"

# ---------------------------------------------
# Set kitty as default terminal (where supported)
# ---------------------------------------------
if command -v update-alternatives >/dev/null 2>&1; then
    update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/kitty 50
    update-alternatives --set x-terminal-emulator /usr/local/bin/kitty
fi

if command -v gsettings >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" && -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    sudo -u "$TARGET_USER" gsettings set \
        org.gnome.desktop.default-applications.terminal exec kitty || true
else
    SKIPPED_ITEMS+=("GNOME terminal default: no graphical D-Bus session")
fi

# ---------------------------------------------
# Set zsh as default shell
# ---------------------------------------------
if command -v zsh >/dev/null 2>&1; then
    ZSH_PATH="$(get_zsh_path)"
    ensure_shell_is_allowed "$ZSH_PATH"
    chsh -s "$ZSH_PATH" "$TARGET_USER"
fi

echo
echo "Installation summary"
echo "Package manager: $PKG_MANAGER"
print_list "Installed or already present:" "${INSTALLED_PACKAGES[@]}"
print_list "Failed or unavailable:" "${FAILED_PACKAGES[@]}"
print_list "Skipped:" "${SKIPPED_ITEMS[@]}"
echo
echo "Installation complete."
echo "Log out and log back in to finish shell & terminal changes."
