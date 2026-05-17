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

install_packages() {
    local package

    for package in "$@"; do
        install_package "$package"
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

# ---------------------------------------------
# Package manager detection
# ---------------------------------------------
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    PKG_INSTALL_CMD=(apt install -y)
    apt update

    install_packages \
        kitty \
        neovim \
        zsh \
        git \
        curl \
        shellcheck \
        luarocks \
        build-essential \
        sshpass \
        xinput \
        docker.io \
        docker-compose-plugin \
        docker-compose \
        ripgrep \
        fd-find \
        nodejs \
        npm \
        python3 \
        python3-pip \
        wl-clipboard \
        xclip
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    PKG_INSTALL_CMD=(dnf install -y)

    install_packages \
        kitty \
        neovim \
        zsh \
        git \
        curl \
        ShellCheck \
        luarocks \
        gcc \
        gcc-c++ \
        make \
        sshpass \
        xinput \
        docker \
        docker-compose-plugin \
        docker-compose \
        ripgrep \
        fd-find \
        nodejs \
        npm \
        python3 \
        python3-pip \
        wl-clipboard \
        xclip
elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
    PKG_INSTALL_CMD=(pacman -S --needed --noconfirm)
    pacman -Sy

    install_packages \
        kitty \
        neovim \
        zsh \
        git \
        curl \
        shellcheck \
        luarocks \
        base-devel \
        sshpass \
        xorg-xinput \
        docker \
        docker-compose \
        ripgrep \
        fd \
        nodejs \
        npm \
        python \
        python-pip \
        wl-clipboard \
        xclip
else
    echo "Unsupported distro: no known package manager found."
    exit 1
fi

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
link_dir "$SETUP_DIR/zsh/bin" "$TARGET_HOME/.local/bin"

# ---------------------------------------------
# Set kitty as default terminal (where supported)
# ---------------------------------------------
if command -v update-alternatives >/dev/null 2>&1; then
    update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
    update-alternatives --set x-terminal-emulator /usr/bin/kitty
fi

if command -v gsettings >/dev/null 2>&1; then
    sudo -u "$TARGET_USER" gsettings set \
        org.gnome.desktop.default-applications.terminal exec kitty || true
fi

# ---------------------------------------------
# Set zsh as default shell
# ---------------------------------------------
if command -v zsh >/dev/null 2>&1; then
    chsh -s "$(command -v zsh)" "$TARGET_USER"
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
