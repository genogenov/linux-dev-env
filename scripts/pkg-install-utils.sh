#! /usr/bin/env bash
[[ -n "${_PKG_INSTALL_UTILS_SH_INCLUDED_-}" ]] && return
_PKG_INSTALL_UTILS_SH_INCLUDED_=1

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$LIB_DIR/utils.sh"

update_system() {
   info "Updating system packages"
   run sudo pacman -Syu --noconfirm
}

install_packages_from_file() {
   local path="$1"
   #pacman or yay
   local installer="${2:-pacman}"
   if [[ -z "$path" ]]; then
       error "Package list path not provided";
         exit 0;
   fi
   if [[ ! -f "$path" ]]; then
       error "Package list file '$path' does not exist";
         exit 0;
   fi

   info "Reading package list from ${path}"
   while IFS= read -r line || [[ -n "$line" ]]; do
       # Skip empty lines and comments
       [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
       info "($installer) Installing package(s): $line"
       case "$installer" in
           pacman)
               run sudo pacman -S --noconfirm --needed $line
               ;;
           yay)
               run yay -S --noconfirm --needed $line
               ;;
           *)
               error "Unsupported installer: $installer"
               exit 1
               ;;
       esac 
   done < "$path"
}