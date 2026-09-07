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

        if read_yes_no "Enable NVIDIA suspend/resume/hibernate services? (required for NVreg_PreserveVideoMemoryAllocations to work)"; then
            info "Enabling nvidia-suspend.service, nvidia-resume.service, nvidia-hibernate.service..."
            run sudo systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service
            success "NVIDIA suspend services enabled."
        else
            info "Skipping NVIDIA suspend services setup."
        fi
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

setup_travel_mode() {
    if ! read_yes_no "Install the 'travelmode' CLI (keeps this machine awake and reachable while you are away)?"; then
        info "Skipping travelmode setup."
        return 0
    fi

    if ! command -v cargo >/dev/null 2>&1; then
        info "Rust toolchain not found. Installing rustup..."
        run sudo pacman -S --noconfirm --needed rustup
        run rustup default stable
        success "Rust toolchain installed successfully."
    fi

    info "Building travelmode..."
    run cargo build --release --locked --manifest-path "$ROOT_DIR/travelmode/Cargo.toml"

    info "Installing travelmode to /usr/local/bin ..."
    run sudo install -Dm755 "$ROOT_DIR/travelmode/target/release/travelmode" /usr/local/bin/travelmode
    success "travelmode installed successfully."

    # stay-awake.service ships with the rest of etc/; make systemd pick it up.
    info "Reloading systemd units..."
    run sudo systemctl daemon-reload

    # Travel mode used to carry its side effects as ExecStartPre/ExecStopPost in
    # a drop-in. They live in the CLI now, and the leftover would override the
    # shipped unit and undo travel mode behind the tool's back.
    local legacy_dropin="/etc/systemd/system/stay-awake.service.d"
    if [[ -d "$legacy_dropin" ]]; then
        warn "Found legacy drop-in $legacy_dropin, superseded by the travelmode CLI."
        if read_yes_no "Remove $legacy_dropin?"; then
            run sudo rm -rf "$legacy_dropin"
            run sudo systemctl daemon-reload
            success "Legacy drop-in removed."
        else
            warn "Keeping $legacy_dropin - it still overrides the shipped unit."
        fi
    fi

    info "Installing travel mode does not arm it. Arm with 'sudo travelmode on', check with 'travelmode status'."
}
