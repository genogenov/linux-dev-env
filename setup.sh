#!/usr/bin/env bash

set -eEuo pipefail

# Created by argbash-init v2.11.0
# Run 'argbash --strip user-content "/home/ggenov/personal/git/setup-parsing.m4" -o "/home/ggenov/personal/git/setup-parsing.sh"' to generate the '/home/ggenov/personal/git/setup-parsing.sh' file.
# If you need to make changes later, edit '/home/ggenov/personal/git/setup-parsing.sh' directly, and regenerate by running
# 'argbash --strip user-content "/home/ggenov/personal/git/setup-parsing.sh" -o "/home/ggenov/personal/git/setup-parsing.sh"'
script_dir="$(cd "$(dirname "$(readlink -e "${BASH_SOURCE[0]}")")" && pwd)"
. "${script_dir}/setup-parsing.sh" || { echo "Couldn't find 'setup-parsing.sh' parsing library in the '$script_dir' directory"; exit 1; }

handle_error() {
    local exit_code=$?
    local last_command=$BASH_COMMAND
    local line_num=$LINENO
    error "An error occurred during script execution.ERROR on line $line_num: Command '\"$last_command\"' failed."
    exit $exit_code;
}

trap 'handle_error' ERR


ROOT_DIR="${script_dir}"
if [[ -n "$_arg_root_dir" ]]; then
    ROOT_DIR="$_arg_root_dir"
fi

source "${ROOT_DIR}/scripts/utils.sh"

DRY_RUN=false
[[ $_arg_dry_run == "on" ]] && DRY_RUN=true

warn "Value of 'ROOT_DIR': $ROOT_DIR"
warn "Value of 'DRY_RUN': $DRY_RUN"
warn "'dry-run' is $_arg_dry_run"
warn "Value of 'command': $_arg_command"