#! /bin/bash

export asm_comp=nasm
export os_name="myos"

export Black='\033[0;30m'
export Red='\033[0;31m'
export Green='\033[0;32m'
export Orange='\033[0;33m'
export Blue='\033[0;34m'
export Purple='\033[0;35m'
export Cyan='\033[0;36m'
export LightGray='\033[0;37m'
export DarkGray='\033[1;30m'
export LightRed='\033[1;31m'
export LightGreen='\033[1;32m'
export Yellow='\033[1;33m'
export LightBlue='\033[1;34m'
export LightPurple='\033[1;35m'
export LightCyan='\033[1;36m'
export White='\033[1;37m'
export NC='\033[0m'

export Bold='\033[1m'
export Underline='\033[4m'
export Reversed='\033[7m'

export obj_dir="obj"
export src_dir="src"
export cc_dir="_CC/bin"
export build_dir="build"

export bootloader_o="bootloader_asm.o"
export kernel_o="kernel_asm.o"
export stage2_o="stage2_asm.o"
export stage2_co="stage2_16c.o"
export bootloader_bin="${build_dir}/bootloader.bin"
export stage2_bin="${build_dir}/stage2.bin"
export kernel_bin="${build_dir}/kernel.bin"

# Linker scripts
export stage2_lds="${src_dir}/bootloader/stage2/linker.lnk"
export stage2_map="${build_dir}/stage2.map"
export floppy_img="${os_name}.img"

function chkfile {
  if [ -f "$1" ]
    then
      return 1
    else
      return 0
    fi
}

function pr_chkfile {

  if [ -f "$1" ]
  then
    echo -e "$1: ${Bold}${Green}ok${NC}"
  else
    echo -e "$1: ${Bold}${Red}NOT FOUND${NC}"
        exit 1
  fi

}

function chk_and_rm {

  if [ -d "$1" ]
  then
    echo -e "Deleting $1 as a ${Purple}directory${NC}"
    rm -r "$1"
  else
    if [ -f "$1" ]
      then
        echo -e "Deleting $1 as a ${Purple}file${NC}"
        rm "$1"
      else
        echo -e "$1: ${Red}NOT FOUND${NC}"
    fi
  fi

}


function read_from_file {

  input="$1"

  echo -e "${Purple}$1${NC}:"

  while IFS= read -r line
  do
    echo -e "${Purple}.${NC}   $line"
  done < "$input"

}


function write_to_file {

  file="$1"
  data="$2"

  echo -e "${data}" > "${file}"
  echo -e "Wrote the following data to ${file}"

  print_file "$1"

}