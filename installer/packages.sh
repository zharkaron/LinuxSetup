#!/usr/bin/env bash

# Distro-aware package manifest.
# Each entry maps a command → the packages that provide it across distros.
# Format: "apt_package dnf_package pacman_package" (space-separated triple).
# If the package name is the same on all three, a single name is sufficient.

# shellcheck disable=SC2034
declare -gA PKG_COMMAND_MAP=(
    [awk]="gawk"
    [bat]="bat bat bat"
    [curl]="curl"
    [dd]="coreutils"
    [docker]="docker.io docker docker"
    [docker-compose]="docker-compose docker-compose docker-compose"
    [eza]="eza eza eza"
    [fd]="fd-find fd-find fd"
    [fzf]="fzf fzf fzf"
    [git]="git"
    [g++]="build-essential gcc-c++ base-devel"
    [gcc]="build-essential gcc base-devel"
    [gradle]="gradle"
    [java]="default-jdk java-latest-openjdk-devel jdk-openjdk"
    [javac]="default-jdk java-latest-openjdk-devel jdk-openjdk"
    [kitten]="kitty"
    [kitty]="kitty"
    [luarocks]="luarocks"
    [make]="build-essential make base-devel"
    [mbsync]="isync isync isync"
    [msmtp]="msmtp msmtp msmtp"
    [mvn]="maven"
    [neomutt]="neomutt neomutt neomutt"
    [notmuch]="notmuch notmuch notmuch"
    [node]="nodejs"
    [npm]="npm"
    [pandoc]="pandoc"
    [nvim]="neovim"
    [pass]="pass pass pass"
    [pip3]="python3-pip python3-pip python-pip"
    [python3]="python3 python3 python"
    [rg]="ripgrep"
    [sha256sum]="coreutils"
    [shellcheck]="shellcheck ShellCheck shellcheck"
    [ssh]="openssh-client openssh-clients openssh"
    [sshpass]="sshpass"
    [sudo]="sudo"
    [sync]="coreutils"
    [tar]="tar"
    [wl-copy]="wl-clipboard"
    [zoxide]="zoxide zoxide zoxide"
    [xclip]="xclip"
    [xdg-open]="xdg-utils"
    [xinput]="xinput xinput xorg-xinput"
    [zsh]="zsh"
)

PKG_REQUIRED_PACKAGES=()
PKG_OPTIONAL_PACKAGES=()
PKG_OPTIONAL_REASON=""
PKG_MANIFEST_COMMANDS=()
declare -gA PKG_COMMAND_PACKAGES=()

load_package_manifest() {
    local manager="$1"
    local manager_idx=0

    PKG_REQUIRED_PACKAGES=()
    PKG_OPTIONAL_PACKAGES=()
    PKG_OPTIONAL_REASON=""
    PKG_MANIFEST_COMMANDS=()
    PKG_COMMAND_PACKAGES=()

    case "$manager" in
        apt)   manager_idx=1 ;;
        dnf)   manager_idx=2 ;;
        pacman) manager_idx=3 ;;
        *)
            echo "Unsupported package manifest: $manager" >&2
            return 1
            ;;
    esac

    local cmd entry pkg i
    for cmd in "${!PKG_COMMAND_MAP[@]}"; do
        entry="${PKG_COMMAND_MAP[$cmd]}"
        # Split by spaces into array
        IFS=' ' read -ra parts <<< "$entry"
        if [[ ${#parts[@]} -eq 1 ]]; then
            # Single value → same package name on all distros
            PKG_COMMAND_PACKAGES["$cmd"]="${parts[0]}"
        elif [[ ${#parts[@]} -eq 3 ]]; then
            # Triple → distro-specific
            i=$((manager_idx - 1))
            PKG_COMMAND_PACKAGES["$cmd"]="${parts[$i]}"
        else
            echo "Warning: invalid manifest entry for '$cmd': '$entry'" >&2
        fi
    done

    PKG_MANIFEST_COMMANDS=("${!PKG_COMMAND_PACKAGES[@]}")

    case "$manager" in
        apt)
            PKG_REQUIRED_PACKAGES=(
                zsh git curl tar shellcheck luarocks build-essential
                sshpass xinput ripgrep fd-find nodejs npm
                python3 python3-pip wl-clipboard xclip pandoc
                fzf zoxide eza bat
            )
            PKG_OPTIONAL_REASON="optional Docker/Compose and mail tools"
            PKG_OPTIONAL_PACKAGES=(
                docker.io docker-compose-plugin docker-compose
                neomutt isync msmtp notmuch pass
            )
            ;;
        dnf)
            PKG_REQUIRED_PACKAGES=(
                zsh git curl tar ShellCheck luarocks
                gcc gcc-c++ make sshpass xinput ripgrep fd-find
                nodejs npm python3 python3-pip wl-clipboard xclip pandoc
                fzf zoxide eza bat
            )
            PKG_OPTIONAL_REASON="optional Docker/Compose and mail tools; availability depends on enabled repos"
            PKG_OPTIONAL_PACKAGES=(
                docker docker-compose-plugin docker-compose
                neomutt isync msmtp notmuch pass
            )
            ;;
        pacman)
            PKG_REQUIRED_PACKAGES=(
                zsh git curl tar shellcheck luarocks base-devel
                sshpass xorg-xinput ripgrep fd
                nodejs npm python python-pip wl-clipboard xclip pandoc
                fzf zoxide eza bat
            )
            PKG_OPTIONAL_REASON="optional Docker/Compose and mail tools"
            PKG_OPTIONAL_PACKAGES=(
                docker docker-compose
                neomutt isync msmtp notmuch pass
            )
            ;;
    esac
}

package_for_command() {
    local command_name="$1"
    printf '%s\n' "${PKG_COMMAND_PACKAGES[$command_name]:-}"
}
