source consts.sh

echo "Checking for linker script for '${ARCH}'"
check_file "dev/kernel/arch/$ARCH/linker.ld"

# Flatten the OBJ dir first
echo "Flattening '${LIB_DIR}'"
chk_rm flattened
mkdir -p flattened

find $LIB_DIR -maxdepth 10 -type f -exec mv -i '{}' flattened/ ';'

mv flattened $LIB_DIR/flat
rm -r flattened

# Link
echo "linking..."
$TARGET-gcc -T "dev/kernel/arch/$ARCH/linker.ld" -o $BINARY -ffreestanding -O2 -nostdlib $LIB_DIR/flat/*.o -lgcc

echo -e "BIN:   ${BINARY} ${Green}Compiled Successfully${NC}"
