#! /bin/bash

source _compilers/consts.sh
# shellcheck disable=SC2154
# using wcc

# "$1": Source
# "$2": Dest

# Make sure that the source file exists,
# make sure that the destination file does not
pr_chkfile "$1"
chk_and_rm "$2"

C16flags="-4 -d3 -s -wx -ms -zl -zq"
# shellcheck disable=SC2154
#cc="${cc_dir}/gcc"
cc=/usr/bin/watcom/binl64/wcc

echo "$cc" "${C16flags}" "$1" -fo="$2"
"${cc}" "${C16flags}" "$1" -fo="$2"
