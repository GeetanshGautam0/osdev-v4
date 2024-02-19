source consts.sh

check_file $BINARY  # Check that the binary exists
if grub-file --is-x86-multiboot $BINARY; then
    echo -e "GRUB:    ${BINARY} - ${Green}multiboot verified${NC}"
else
    echo -e "GRUB:    ${BINARY} - ${Red}NOT MULTIBOOT${NC}"
fi
