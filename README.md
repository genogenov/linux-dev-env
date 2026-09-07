# Arch Linux Development Environment

A comprehensive setup repository for configuring a complete Arch Linux development environment with Hyprland, including automated installation scripts, configuration files, and system optimizations.

## Overview

This repository contains everything needed to set up a fully functional Arch Linux system with:
- **Hyprland** wayland compositor
- **NVIDIA** driver configuration with proper kernel parameters
- **Development tools** and utilities
- **Automated package installation** (pacman + AUR)
- **System configuration files** for various services
- **Custom shell configurations**

📌 See [TODO.md](TODO.md) for planned features and improvements.

## Quick Start

The main setup script provides three commands for system configuration:

```bash
./setup-arch system   # Setup base system (time/date sync, yay, etc.)
./setup-arch install  # Install pacman and AUR packages
./setup-arch config   # Deploy configuration files
```

### Options
- `-r, --root-dir <path>` - Specify a different root directory for configs/scripts
- `-d, --dry-run` - Perform a trial run without making changes
- `-h, --help` - Display help information

## Project Structure

```
linux-dev-env/
├── setup-arch              # Main setup script (generated from .m4)
│
script
├── pacman-pkgs.txt         # Official repository packages list
├── aur-pkgs.txt            # AUR packages list
├── TODO.md                 # Planned features and improvements
│
├── etc/                    # System configuration files (/etc)
│   ├── greetd/            # Display manager configuration
│   │   ├── config.toml    # Main greetd config
│   │   ├── hyprland.conf  # Hyprland session for greeter
│   │   └── regreet.toml   # ReGreet greeter settings
│   ├── pacman/
│   │   └── pacman.conf    # Pacman package manager configuration
│   └── systemd/system/
│       └── stay-awake.service  # Travel mode inhibitor unit
|
├── .config/               # Configuration files
|
├── ghostty/               # Ghostty terminal emulator config
│   └── config             # Terminal settings and appearance
│
├── modprobe.d/            # Kernel module parameters
│
├── scripts/               # Utility shell scripts
│
├── travelmode/            # `travelmode` CLI (Rust) - travel mode on/off/status
│
├── shell/                 # Shell configuration files
│
├── udev/                  # Udev device rules
│
└── wallpapers/            # Desktop wallpapers collection. AI generated.
```

## Configuration Details

## cripts

### Main Setup Script (`setup-arch`)
Generated arg parsing using **argbash** :
- **system** - Initialize base system, configure time sync, install AUR helper (yay)
- **install** - Install all packages from pacman-pkgs.txt and aur-pkgs.txt
- **config** - Deploy configuration files to appropriate system locations

### Travel Mode (`travelmode`)
A small Rust CLI for leaving this machine at home and reaching it over SSH.
Built and installed to `/usr/local/bin` by `./setup-arch config`.

```bash
sudo travelmode on      # block sleep + lid suspend, pin wifi awake, no greeter on boot
sudo travelmode off     # put everything back the way it lives at home
travelmode status       # what is armed right now
travelmode on --dry-run # print the exact commands instead of running them
```

Travel mode is three reversible facts about the machine, all owned by the CLI:
- `stay-awake.service` holds a `systemd-inhibit` on `sleep:handle-lid-switch`.
  `idle` is deliberately excluded so **hypridle** still dims, locks and blanks
  the screen while the machine sits awake and alone.
- Wifi power saving is turned off in the NetworkManager profiles *and* on the
  live association (`nmcli modify` alone does not touch the current one), so the
  card stays reachable with nobody at the keyboard.
- `greetd` is **disabled, never stopped** - stopping it drops the PAM handle for
  the logged-in session and logind takes Hyprland down with it. Disabling is all
  that is needed for a greeter-free boot.

`travelmode off` re-enables greetd but will not *start* it while a graphical
session is live (starting it switches the screen to VT1); pass
`--start-greeter` to do it anyway.

### Utility Scripts
- `scripts/arch-utils.sh` - Arch-specific helper functions
- `scripts/pkg-install-utils.sh` - Package management utilities
- `scripts/utils.sh` - General-purpose shell functions
- `scripts/fix-raptorlake-sound.sh` - TAS2781 speaker init for Raptor Lake laptops

## Notes
- This configuration is optimized for systems with **NVIDIA + Intel** hybrid graphics
- Designed for **Hyprland** wayland compositor
- Uses **greetd** instead of traditional display managers for better wayland support

## Regenerating Setup Script
The setup script is generated using **argbash**:

```bash
argbash ./setup-arch -o setup-arch
chmod +x setup-arch
```

## License

Personal configuration repository. Use at your own discretion.

---

*Last updated: January 2026*
