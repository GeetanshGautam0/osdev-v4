#! /bin/bash
# shellcheck disable=SC2154

source _compilers/consts.sh

#c_tools_compiler="$cc_dir/i686-elf-gcc"
tools_compiler=gcc
echo -e "Using ${Purple}$tools_compiler${NC} to compile $1"
echo -e "${Orange}WARNING: DO NOT USE THIS FILE FOR OS COMPILATION${NC}"

# Args:
#   $1:   SOURCE C file (must exist)
#   $2:   DEST   O file
#   $3:   DEST DIR

# Check if $1 exists
pr_chkfile "$1"

# If $2 exists, delete it
chk_and_rm "$2"

mkdir -p "$3"

echo $tools_compiler "$1" -g -o "$2"
$tools_compiler "$1" -g -o "$2"
