#! /bin/bash -x

source consts.sh
check_file "$1"

# $1: First arg - source file
# $2: Second arg - dest file
# shellcheck disable=SC2086
"$TARGET-g++" -c "$1" -o "$2" $C_DEFINES -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
