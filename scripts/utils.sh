#! /usr/bin/env bash

[[ -n "${_UTILS_SH_INCLUDED_-}" ]] && return
_UTILS_SH_INCLUDED_=1

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
        local exit_code
        "$@" || exit_code=$? 
        exit_code=${exit_code:-0}

        if [ $exit_code -ne 0 ]; then
            error "Error: Command '$*' failed with exit code $exit_code."
            return $exit_code
        fi
        return 0
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
