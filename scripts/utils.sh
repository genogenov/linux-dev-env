#! /usr/bin/env bash

set -euo pipefail

if [[ -t 1 ]]; then
    BOLD="\033[1m";
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

run(){
    if $DRY_RUN; then
        info "[DRY RUN] $*"
    else
        "$@"
    fi
}

read_yes_no() {
    while true; do
        read -p "$1 [y/N]: " response
        case "$response" in
            [Yy][Ee][Ss]|[Yy]) 
                return 0  # Yes
                ;;
            [Nn][Oo]|[Nn]|"")
                return 1  # No (or just Enter)
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

update_system() {
   info "Updating system packages"
   run sudo pacman -Syu --noconfirm
}

install_packages() {
   local path="$$"
   if [[ -n "$1" ]]; then
       error "Package list path not provided";
         exit 1;
   fi
   if [[ ! -f "$1" ]]; then
       error "Package list file '$1' does not exist";
         exit 1;
   fi

   info "Reading package list from ${path}"
   local packages=()
   while IFS= read -r line; do
         # Skip comments and empty lines
         [[ "$line" =~ ^#.*$ ]] && continue
         [[ -z "$line" ]] && continue
         packages+=("$line")
    done < "${path}"
   info "Installing packages: ${packages[*]}" 

   run sudo pacman -S --noconfirm --needed "${packages[@]}"
}
