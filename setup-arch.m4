#!/usr/bin/env bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11  #)Created by argbash-init v2.11.0
# ARG_OPTIONAL_SINGLE([root-dir],[r],[Path to the repository root directory])
# ARG_OPTIONAL_BOOLEAN([dry-run],[d],[Perform a trial run with no changes made])
# ARG_POSITIONAL_SINGLE([command],[The command to execute])
# ARG_TYPE_GROUP_SET([ops],[op],[command],[install])
# ARG_DEFAULTS_POS
# ARG_HELP([Arch "setup everything" script.],[Arch Linux setup script for packages, configs, udev rules, ketnel flags, etc.])
# ARGBASH_GO

# [ <-- needed because of Argbash

# vvv  PLACE YOUR CODE HERE  vvv
# For example:
printf 'Value of --%s: %s\n' 'root-dir' "$_arg_root_dir"
printf "'%s' is %s\\n" 'dry-run' "$_arg_dry_run"
printf "Value of '%s': %s\\n" 'command' "$_arg_command"

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
