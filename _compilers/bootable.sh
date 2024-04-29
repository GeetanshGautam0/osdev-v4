#! /bin/bash
# shellcheck disable=SC2154

source _compilers/consts.sh

# Check to make sure that the binary exists
pr_chkfile "$bootloader_bin"

# Remove the previous image
chk_and_rm "$floppy_img"

# Make a floppy image
# This will be a FAT12 disk image
# dd:
  # if: in file
  # of: out file
  # bs: block size: 512 bytes
  # count: block count: 2880 blocks
dd if=/dev/zero of="$floppy_img" bs=512 count=2880

# mkfs.fat:     make file system (FAT)
  # F:  FAT 12
  # n: name

mkfs.fat -F 12 -n "$os_name" "$floppy_img"
dd if="$bootloader_bin" of="$floppy_img" conv=notrunc     # Do not truncate
mcopy -i "$floppy_img" "$stage2_bin" "::stage2.bin"
mcopy -i "$floppy_img" "$kernel_bin" "::kernel.bin"
mcopy -i "$floppy_img" GGOS "::/GGOS"
mcopy -i "$floppy_img" GGOS/DIR "::/GGOS/DIR"

chkfile "$floppy_img"
_rv07=$?

if [ "$_rv07" == 1 ]
then
    echo -e "Bootable image ${Green}${floppy_img}${NC} created."
else
    echo -e "${Red}Failed to create bootable image.${NC}"
fi
