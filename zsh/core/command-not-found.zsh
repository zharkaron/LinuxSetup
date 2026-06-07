SETUP_DIR="$(cd "$ZSH_ROOT/.." && pwd)"
source "$SETUP_DIR/installer/packages.sh"

_detect_package_manager() {
    if [[ -f /etc/os-release ]]; then
        local id id_like
        id=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
        id_like=$(grep '^ID_LIKE=' /etc/os-release | cut -d= -f2 | tr -d '"')

        case "${id:l}" in
            ubuntu|debian|linuxmint|pop|elementary|zorin|kali) echo "apt"; return ;;
            fedora|rhel|centos|rocky|almalinux) echo "dnf"; return ;;
            arch|archlinux|endeavouros|manjaro|artix) echo "pacman"; return ;;
        esac

        case ",${id_like:l}," in
            *,debian,*) echo "apt"; return ;;
            *,fedora,*|*,rhel,*) echo "dnf"; return ;;
            *,arch,*) echo "pacman"; return ;;
        esac
    fi

    command -v apt >/dev/null 2>&1 && echo "apt" && return
    command -v dnf >/dev/null 2>&1 && echo "dnf" && return
    command -v pacman >/dev/null 2>&1 && echo "pacman" && return

    echo ""
}

_install_with_package_manager() {
    local manager="$1" package="$2"

    case "$manager" in
        apt)   sudo apt install -y "$package" ;;
        dnf)   sudo dnf install -y "$package" ;;
        pacman) sudo pacman -S --needed --noconfirm "$package" ;;
    esac
}

function command_not_found_handler() {
    local cmd="$1"

    [[ -o interactive ]] || return 1

    local manager
    manager=$(_detect_package_manager)
    if [[ -z "$manager" ]]; then
        echo "zsh: command not found: $cmd" >&2
        return 1
    fi

    load_package_manifest "$manager" 2>/dev/null

    local pkg
    pkg=$(package_for_command "$cmd")

    if [[ -z "$pkg" ]]; then
        echo "zsh: command not found: $cmd" >&2
        return 1
    fi

    if [[ ! -t 0 ]]; then
        echo "zsh: command not found: $cmd (install with: ${manager} install ${pkg})" >&2
        return 1
    fi

    echo -n "Command \`${cmd}\` is not installed. Install package \`${pkg}\` with ${manager}? [y/N] "
    local answer
    read -r answer
    if [[ "$answer" =~ ^[yY] ]]; then
        if _install_with_package_manager "$manager" "$pkg"; then
            eval "$@"
        else
            echo "zsh: failed to install package \`${pkg}\`" >&2
            return 1
        fi
    fi
}
