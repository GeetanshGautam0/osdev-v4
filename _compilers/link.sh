#! /bin/bash
# shellcheck disable=SC2154

source _compilers/consts.sh

# Check that all relevant linker scripts exist
echo "Checking for appropriate linker scripts"
pr_chkfile "${stage2_lds}"

# Flatten the OBJ dir first
echo "Flattening '${obj_dir}'"

function crdir {

  chk_and_rm "$1"
  mkdir "$1"

  if [ -d "$1" ]; then true; else
    echo -e "${Red}Could not make the directory '$1'${NC}"
  fi

}

function flatten
{
  #   $1: output dir
  #   $2: input dir
  #   $3: mode (mv or cp)

  crdir "$1"
  find "$2" -maxdepth 10 -type f -exec $3 -i '{}' "$1/" ';'
  mv "$1" "$obj_dir/$1"

}


flatten "flbs1" "$obj_dir/bootloader/stage1" mv   # Flatten obj/bootloader/stage1 into flbs1 using mv mode
flatten "flbs2" "$obj_dir/bootloader/stage2" mv   # Flatten obj/bootloader/stage2 into flbs2 using mv mode
flatten "flkrnl" "$obj_dir/kernel" mv             # Flatten obj/kernel into flkrnl using mv mode

O16ld=/usr/bin/watcom/binl64/wlink

# Make the build dir
mkdir -p "${build_dir}"

# Get the raw bootloader binaries
# Stage 1: ASM OBJ -> BIN
echo cp "${obj_dir}/flbs1/${bootloader_o}" "${bootloader_bin}"
cp "${obj_dir}/flbs1/${bootloader_o}" "${bootloader_bin}"

# Stage 2: 16 bit link
echo $O16ld NAME "${stage2_bin}" FILE \{ $(echo "$obj_dir"/flbs2/*.o) \} OPTION MAP="${stage2_map}" "@${stage2_lds}"
$O16ld NAME "${stage2_bin}" FILE \{ $(echo "$obj_dir"/flbs2/*.o) \} OPTION MAP="${stage2_map}" "@${stage2_lds}"

# Temporary kernel binary
#linker_flags="-ffreestanding"
echo cp "${obj_dir}/flkrnl/${kernel_o}" "${kernel_bin}"
cp "${obj_dir}/flkrnl/${kernel_o}" "${kernel_bin}"


# Check to make sure that the binary exists
pr_chkfile "$bootloader_bin"
echo -e "${Green}Linked${NC}"