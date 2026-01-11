#! /usr/bin/env bash

[[ -n "${_UTILS_SH_INCLUDED_-}" ]] && return
_UTILS_SH_INCLUDED_=1

if [[ -t 1 ]]; then
    BOLD="\033[1m"
    RESET="\033[0m"
    RED="\033[31m"
    GREEN="\033[32m"
    YELLOW="\033[33m"
    BLUE="\033[34m"
else
    BOLD=""
    RESET=""
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
fi

# Function to print info
info() { printf "${BOLD}${BLUE}>>> ${RESET}${BOLD}%s\n${RESET}" "$*"; }
success() { printf "${BOLD}${GREEN}>>> ${RESET}${BOLD}%s\n${RESET}" "$*"; }
warn() { printf "${BOLD}${YELLOW}>>> ${RESET}${BOLD}%s\n${RESET}" "$*"; }
error() { printf "${BOLD}${RED}>>> %s\n${RESET}" "$*"; }

run() {
    if $DRY_RUN; then
        info "[DRY RUN] $*"
    else
        local exit_code
        "$@" || exit_code=$?
        exit_code=${exit_code:-0}

        if [ $exit_code -ne 0 ]; then
            error "Error: Command '$*' failed with exit code $exit_code."
            exit $exit_code
        fi
        return 0
    fi
}

read_yes_no() {
    while true; do
        read -p "$1 [y/N]: " response
        case "$response" in
        [Yy][Ee][Ss] | [Yy])
            return 0 # Yes
            ;;
        [Nn][Oo] | [Nn] | "")
            return 1 # No (or just Enter)
            ;;
        *)
            echo "Please answer yes or no."
            ;;
        esac
    done
}

setup_udev_rules() {
    if read_yes_no "Setup udev rules?"; then
        info "Setting up udev rules..."
        run sudo cp -rv $ROOT_DIR/udev/rules.d/. /etc/udev/rules.d/
        success "Udev rules setup successfully."
        info "Reloading udev rules..."
        run sudo udevadm control --reload-rules
        run sudo udevadm trigger
        success "Udev rules reloaded successfully."
    else
        info "Skipping udev rules setup."
    fi
}

setup_shell() {
    info "Installing Oh My Zsh..."
    if [[ ! -d ~/.oh-my-zsh ]]; then
        run sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        success "Oh My Zsh installed successfully."
    else
        info "Oh My Zsh is already installed. Skipping installation."
    fi

    info "Installing Zsh Shift Select Mode plugin..."
    if [[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-shift-select ]]; then
        run git clone https://github.com/jirutka/zsh-shift-select.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-shift-select
        success "Zsh Shift Select Mode plugin installed successfully."
    else
        info "Zsh Shift Select Mode plugin is already installed. Skipping installation."
    fi

    info "Copying shell profile settings..."
    run cp -rv $ROOT_DIR/shell/. ~/
    success "Shell profile settings copied successfully."

    info "Setting Zsh as the default shell..."
    local new_shell=$(which zsh)
    if [ "$SHELL" != "$new_shell" ]; then
        run chsh -s "$new_shell"
        success "Zsh set as the default shell successfully."
        warn "Shell changed. Please log out and back in for changes to take effect."
    else
        info "Shell is already $new_shell. No change needed."
    fi
}
