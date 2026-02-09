#!/usr/bin/env bash
set -Eeuo pipefail

# ─────────────────────────────────────────────
# Re-run as root if needed
# ─────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo "Re-running installer as root..."
    exec sudo "$0" "$@"
fi

# ─────────────────────────────────────────────
# Detect real user (not root)
# ─────────────────────────────────────────────
TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing for user: $TARGET_USER"
echo "Home directory: $TARGET_HOME"
echo "Repo directory: $SETUP_DIR"

# ─────────────────────────────────────────────
# Package manager detection
# ─────────────────────────────────────────────
if command -v apt >/dev/null 2>&1; then
    PKG_INSTALL="apt install -y"
    apt update
    $PKG_INSTALL kitty neovim zsh build-essential curl shellcheck luarocks
elif command -v dnf >/dev/null 2>&1; then
    PKG_INSTALL="dnf install -y"
    $PKG_INSTALL kitty neovim zsh gcc gcc-c++ make curl ShellCheck luarocks
elif command -v pacman >/dev/null 2>&1; then
    pacman -Sy --noconfirm kitty neovim zsh base-devel curl shellcheck luarocks
else
    echo "Unsupported distro: no known package manager found."
    exit 1
fi

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────
link_dir() {
    local src="$1"
    local dest="$2"

    echo "Linking $dest → $src"
    rm -rf "$dest"
    ln -s "$src" "$dest"
    chown -h "$TARGET_USER:$TARGET_USER" "$dest"
}

link_file() {
    local src="$1"
    local dest="$2"

    echo "Linking $dest → $src"
    rm -f "$dest"
    ln -s "$src" "$dest"
    chown -h "$TARGET_USER:$TARGET_USER" "$dest"
}

# ─────────────────────────────────────────────
# Create base directories
# ─────────────────────────────────────────────
sudo -u "$TARGET_USER" mkdir -p "$TARGET_HOME/.config"
sudo -u "$TARGET_USER" mkdir -p "$TARGET_HOME/.local/bin"

# ─────────────────────────────────────────────
# Kitty
# ─────────────────────────────────────────────
link_dir "$SETUP_DIR/kitty" "$TARGET_HOME/.config/kitty"

# ─────────────────────────────────────────────
# Neovim
# ─────────────────────────────────────────────
link_dir "$SETUP_DIR/nvim" "$TARGET_HOME/.config/nvim"
luarocks install luacheck

# ─────────────────────────────────────────────
# Zsh
# ─────────────────────────────────────────────
link_file "$SETUP_DIR/zsh/zshrc" "$TARGET_HOME/.zshrc"
link_dir "$SETUP_DIR/zsh/bin" "$TARGET_HOME/.local/bin"

# ─────────────────────────────────────────────
# Set kitty as default terminal (where supported)
# ─────────────────────────────────────────────
if command -v update-alternatives >/dev/null 2>&1; then
    update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
    update-alternatives --set x-terminal-emulator /usr/bin/kitty
fi

if command -v gsettings >/dev/null 2>&1; then
    sudo -u "$TARGET_USER" gsettings set \
        org.gnome.desktop.default-applications.terminal exec kitty || true
fi

# ─────────────────────────────────────────────
# Set zsh as default shell
# ─────────────────────────────────────────────
if command -v zsh >/dev/null 2>&1; then
    chsh -s "$(command -v zsh)" "$TARGET_USER"
fi

echo
echo "✅ Installation complete."
echo "Log out and log back in to finish shell & terminal changes."

