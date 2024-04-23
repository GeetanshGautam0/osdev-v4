#! /bin/bash
# shellcheck disable=SC2154

source _compilers/consts.sh
# using wcc

# "$1": Source
# "$2": Dest

# Make sure that the source file exists,
# make sure that the destination file does not
pr_chkfile "$1"
chk_and_rm "$2"

C16flags="-4 -d3 -s -wx -ms -zl -zq -za99"
cc=/usr/bin/watcom/binl64/wcc

echo "$cc" "${C16flags}" "$1" -fo="$2"
"${cc}" "${C16flags}" "$1" -fo="$2"

chkfile "$2"
_rv52=$?

if [ "$_rv52" == 1 ]
then
  echo -e "${Green}Compiled $2 successfully${NC}"
else
  echo -e "${Red}Could not compile $2${NC}"
  exit 1
fi
