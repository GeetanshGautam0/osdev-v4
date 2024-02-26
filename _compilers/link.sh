#! /bin/bash
# shellcheck disable=SC2154

source _compilers/consts.sh

# Check that all relevant linker scripts exist
echo "Checking for appropriate linker scripts"
pr_chkfile "${stage2_lds}"

# Flatten the OBJ dir first
echo "Flattening '${obj_dir}'"
chk_and_rm "flattened"
mkdir "flattened"

if [ -d "flattened" ]; then true; else
  echo -e "${Red}Could not make the directory 'flattened'${NC}"
fi

find "$obj_dir" -maxdepth 10 -type f -exec cp -i '{}' flattened/ ';'
mv flattened "$obj_dir/flat"

O16ld=/usr/bin/watcom/binl64/wlink

# Make the build dir
mkdir -p "${build_dir}"

# Get the raw bootloader binaries
# Stage 1: ASM OBJ -> BIN
echo cp "${obj_dir}/flat/${bootloader_o}" "${bootloader_bin}"
cp "${obj_dir}/flat/${bootloader_o}" "${bootloader_bin}"

# Stage 2: 16 bit link
echo $O16ld NAME "${stage2_bin}" FILE \{ $(echo $obj_dir/bootloader/stage2/*.o) \} OPTION MAP="${stage2_map}" "@${stage2_lds}"
$O16ld NAME "${stage2_bin}" FILE \{ $(echo $obj_dir/bootloader/stage2/*.o) \} OPTION MAP="${stage2_map}" "@${stage2_lds}"

# Temporary kernel binary
#linker_flags="-ffreestanding"
echo cp "${obj_dir}/flat/${kernel_o}" "${kernel_bin}"
cp "${obj_dir}/flat/${kernel_o}" "${kernel_bin}"


# Check to make sure that the binary exists
pr_chkfile "$bootloader_bin"
echo -e "${Green}Linked${NC}"
