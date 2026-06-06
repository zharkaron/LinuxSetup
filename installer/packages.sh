#!/usr/bin/env bash

# Package and command manifest used by install.sh and future shell helpers.
# Keep distro-specific names here so install logic can stay small.

# shellcheck disable=SC2034
PKG_REQUIRED_PACKAGES=()
PKG_OPTIONAL_PACKAGES=()
PKG_OPTIONAL_REASON=""
PKG_MANIFEST_COMMANDS=()
declare -gA PKG_COMMAND_PACKAGES=()

load_package_manifest() {
    local manager="$1"

    PKG_REQUIRED_PACKAGES=()
    PKG_OPTIONAL_PACKAGES=()
    PKG_OPTIONAL_REASON=""
    PKG_MANIFEST_COMMANDS=()
    PKG_COMMAND_PACKAGES=()

    case "$manager" in
        apt)
            PKG_REQUIRED_PACKAGES=(
                zsh
                git
                curl
                tar
                shellcheck
                luarocks
                build-essential
                sshpass
                xinput
                ripgrep
                fd-find
                nodejs
                npm
                python3
                python3-pip
                wl-clipboard
                xclip
            )
            PKG_OPTIONAL_REASON="optional Docker/Compose support"
            PKG_OPTIONAL_PACKAGES=(
                docker.io
                docker-compose-plugin
                docker-compose
            )
            PKG_COMMAND_PACKAGES=(
                [awk]="gawk"
                [curl]="curl"
                [dd]="coreutils"
                [docker]="docker.io"
                [docker-compose]="docker-compose"
                [fd]="fd-find"
                [git]="git"
                [g++]="build-essential"
                [gcc]="build-essential"
                [gradle]="gradle"
                [java]="default-jdk"
                [javac]="default-jdk"
                [kitten]="kitty"
                [kitty]="kitty"
                [luarocks]="luarocks"
                [make]="build-essential"
                [mvn]="maven"
                [node]="nodejs"
                [npm]="npm"
                [nvim]="neovim"
                [pip3]="python3-pip"
                [python3]="python3"
                [rg]="ripgrep"
                [sha256sum]="coreutils"
                [shellcheck]="shellcheck"
                [ssh]="openssh-client"
                [sshpass]="sshpass"
                [sudo]="sudo"
                [sync]="coreutils"
                [tar]="tar"
                [wl-copy]="wl-clipboard"
                [xclip]="xclip"
                [xdg-open]="xdg-utils"
                [xinput]="xinput"
                [zsh]="zsh"
            )
            ;;
        dnf)
            PKG_REQUIRED_PACKAGES=(
                zsh
                git
                curl
                tar
                ShellCheck
                luarocks
                gcc
                gcc-c++
                make
                sshpass
                xinput
                ripgrep
                fd-find
                nodejs
                npm
                python3
                python3-pip
                wl-clipboard
                xclip
            )
            PKG_OPTIONAL_REASON="optional Docker/Compose support; package availability depends on enabled repos"
            PKG_OPTIONAL_PACKAGES=(
                docker
                docker-compose-plugin
                docker-compose
            )
            PKG_COMMAND_PACKAGES=(
                [awk]="gawk"
                [curl]="curl"
                [dd]="coreutils"
                [docker]="docker"
                [docker-compose]="docker-compose"
                [fd]="fd-find"
                [git]="git"
                [g++]="gcc-c++"
                [gcc]="gcc"
                [gradle]="gradle"
                [java]="java-latest-openjdk-devel"
                [javac]="java-latest-openjdk-devel"
                [kitten]="kitty"
                [kitty]="kitty"
                [luarocks]="luarocks"
                [make]="make"
                [mvn]="maven"
                [node]="nodejs"
                [npm]="npm"
                [nvim]="neovim"
                [pip3]="python3-pip"
                [python3]="python3"
                [rg]="ripgrep"
                [sha256sum]="coreutils"
                [shellcheck]="ShellCheck"
                [ssh]="openssh-clients"
                [sshpass]="sshpass"
                [sudo]="sudo"
                [sync]="coreutils"
                [tar]="tar"
                [wl-copy]="wl-clipboard"
                [xclip]="xclip"
                [xdg-open]="xdg-utils"
                [xinput]="xinput"
                [zsh]="zsh"
            )
            ;;
        pacman)
            PKG_REQUIRED_PACKAGES=(
                zsh
                git
                curl
                tar
                shellcheck
                luarocks
                base-devel
                sshpass
                xorg-xinput
                ripgrep
                fd
                nodejs
                npm
                python
                python-pip
                wl-clipboard
                xclip
            )
            PKG_OPTIONAL_REASON="optional Docker/Compose support"
            PKG_OPTIONAL_PACKAGES=(
                docker
                docker-compose
            )
            PKG_COMMAND_PACKAGES=(
                [awk]="gawk"
                [curl]="curl"
                [dd]="coreutils"
                [docker]="docker"
                [docker-compose]="docker-compose"
                [fd]="fd"
                [git]="git"
                [g++]="base-devel"
                [gcc]="base-devel"
                [gradle]="gradle"
                [java]="jdk-openjdk"
                [javac]="jdk-openjdk"
                [kitten]="kitty"
                [kitty]="kitty"
                [luarocks]="luarocks"
                [make]="base-devel"
                [mvn]="maven"
                [node]="nodejs"
                [npm]="npm"
                [nvim]="neovim"
                [pip3]="python-pip"
                [python3]="python"
                [rg]="ripgrep"
                [sha256sum]="coreutils"
                [shellcheck]="shellcheck"
                [ssh]="openssh"
                [sshpass]="sshpass"
                [sudo]="sudo"
                [sync]="coreutils"
                [tar]="tar"
                [wl-copy]="wl-clipboard"
                [xclip]="xclip"
                [xdg-open]="xdg-utils"
                [xinput]="xorg-xinput"
                [zsh]="zsh"
            )
            ;;
        *)
            echo "Unsupported package manifest: $manager" >&2
            return 1
            ;;
    esac

    PKG_MANIFEST_COMMANDS=("${!PKG_COMMAND_PACKAGES[@]}")
}

package_for_command() {
    local command_name="$1"

    printf '%s\n' "${PKG_COMMAND_PACKAGES[$command_name]:-}"
}
