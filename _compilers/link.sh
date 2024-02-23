#! /bin/bash
# shellcheck disable=SC2154

source _compilers/consts.sh

# Flatten the OBJ dir first
echo "Flattening '${obj_dir}'"
chk_and_rm "flattened"
mkdir "flattened"

if [ -d "flattened" ]; then true; else
  echo -e "${Red}Could not make the directory 'flattened'${NC}"
fi

find "$obj_dir" -maxdepth 10 -type f -exec mv -i '{}' flattened/ ';'

mv flattened "$obj_dir/flat"

# Make the build dir
mkdir -p "${build_dir}"

# temp
echo -e "${Orange}WARNING (link.sh): ONLY LOADING BOOTLOADER, STAGE2, AND KERNEL_ASM${NC}"
cp "${obj_dir}/flat/${bootloader_o}" "${bootloader_bin}"
cp "${obj_dir}/flat/${stage2_o}" "${stage2_bin}"
cp "${obj_dir}/flat/${kernel_o}" "${kernel_bin}"


# Check to make sure that the binary exists
pr_chkfile "$bootloader_bin"
echo -e "${Green}Linked${NC}"
