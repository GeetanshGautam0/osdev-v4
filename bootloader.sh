source consts.sh

check_file "dev/kernel/arch/$ARCH/boot.s"
"$TARGET-as" "dev/kernel/arch/$ARCH/boot.s" -o "$BOOT_O"

