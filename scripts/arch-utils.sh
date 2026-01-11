#! /usr/bin/env bash

[[ -n "${_ARCH_UTILS_SH_INCLUDED_-}" ]] && return
_ARCH_UTILS_SH_INCLUDED_=1

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/utils.sh"

install_yay() {
    info "Setting up 'yay' AUR helper..."
    if ! command -v yay >/dev/null 2>&1; then
        info "Installing required dependencies for building AUR packages (git, base-devel) if not already installed..."
        run sudo pacman -S --noconfirm --needed git base-devel
        info "Installing yay AUR helper"
        run git clone https://aur.archlinux.org/yay.git /tmp/yay
        pushd /tmp/yay >/dev/null
        run makepkg -si --noconfirm
        popd >/dev/null
        run rm -rf /tmp/yay
        success "Yay AUR helper setup successfully."
    else
        info "'yay' is already installed. Skipping setup."
    fi
}

setup_kernel_modules() {
    if read_yes_no "Setup kernel modules?"; then
        info "Setting up kernel modules..."
        run sudo cp -rv $ROOT_DIR/modprobe.d/. /etc/modprobe.d/
        success "Kernel modules setup successfully."

        if read_yes_no "Preload nvidia modules before boot hooks?"; then
            if grep -q "nvidia" /etc/mkinitcpio.conf; then
                info "Nvidia modules already present in /etc/mkinitcpio.conf. Skipping modification."
            else
                info "Preloading nvidia modules before boot hooks..."
                run sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
                success "Nvidia modules preloaded before boot hooks."
            fi
        else
            info "Skipping nvidia modules preloading setup."
        fi

        info "Regenerating initramfs..."
        run sudo mkinitcpio -P
        success "Initramfs regenerated successfully."
    else
        info "Skipping modprobe modules setup."
    fi
}

setup_pacman_mirrorlist() {
    if read_yes_no "Setup pacman mirrorlist (Reflector)?"; then
        info "Setting up pacman mirrorlist..."
        info "Installing required dependencies (Reflector) if not already installed..."
        run sudo pacman -S --noconfirm --needed reflector

        info "Backing up existing mirrorlist to /etc/pacman.d/mirrorlist.bak ..."
        run sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
        info "Generating new mirrorlist with Reflector..."
        run sudo reflector --country 'United States' --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist --verbose --latest 10
        success "Pacman mirrorlist setup successfully."
        info "Updating pacman database with new mirrorlist..."
        run sudo pacman -Syy
        success "Pacman database updated successfully."
    else
        info "Skipping pacman mirrorlist setup."
    fi
}