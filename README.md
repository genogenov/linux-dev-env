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
├── setup-arch.m4           # Source template for setup script
├── pacman-pkgs.txt         # Official repository packages list
├── aur-pkgs.txt            # AUR packages list
├── todo.txt                # Project tasks and todos
│
├── etc/                    # System configuration files (/etc)
│   ├── greetd/            # Display manager configuration
│   │   ├── config.toml    # Main greetd config
│   │   ├── hyprland.conf  # Hyprland session for greeter
│   │   └── regreet.toml   # ReGreet greeter settings
│   └── pacman/
│       └── pacman.conf    # Pacman package manager configuration
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
├── shell/                 # Shell configuration files
│
├── udev/                  # Udev device rules
│
└── wallpapers/            # Desktop wallpapers collection. AI generated.
```

## Configuration Details

## cripts

### Main Setup Script (`setup-arch`)
Generated from `setup-arch.m4` using **argbash** for robust argument parsing:
- **system** - Initialize base system, configure time sync, install AUR helper (yay)
- **install** - Install all packages from pacman-pkgs.txt and aur-pkgs.txt
- **config** - Deploy configuration files to appropriate system locations

### Utility Scripts
- `scripts/arch-utils.sh` - Arch-specific helper functions
- `scripts/pkg-install-utils.sh` - Package management utilities
- `scripts/utils.sh` - General-purpose shell functions

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
