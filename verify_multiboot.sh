source consts.sh

check_file "$BINARY"                                                # Check that the binary exists
if grub-file --is-x86-multiboot "$BINARY"; then
# shellcheck disable=SC2154
    echo -e "GRUB:    ${BINARY} - ${Green}multiboot verified${NC}"
else
# shellcheck disable=SC2154
    echo -e "GRUB:    ${BINARY} - ${Red}NOT MULTIBOOT${NC}"
fi
