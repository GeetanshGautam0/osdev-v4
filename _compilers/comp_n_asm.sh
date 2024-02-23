#! /bin/bash
# shellcheck disable=SC2154

source _compilers/consts.sh

#   First argument to script ($1)     SOURCE FILE (must exist)
#   Second argument to script ($2)    DESTINATION FILE (remove if exists)

pr_chkfile "$1"                       # Check to make sure that the source file exists
chk_and_rm "$2"                       # Remove the destination file if it exists

echo -e "Using ${Purple}${asm_comp}${NC} to compile $1"

$asm_comp "$1" -f bin -o "$2"         # Compile the file

chkfile "$2"
_rv51=$?

if [ "$_rv51" == 1 ]
then
  echo -e "${Green}Compiled $2 successfully${NC}"
else
  echo -e "${Red}Could not compile $2${NC}"
  exit 1
fi

