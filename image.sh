source consts.sh

# Create a simple grub.cfg file
config="\
menuentry \"${OSNAME}\" {
    multiboot /boot/${BINARY}
}"

write_to_file "grub.cfg" "${config}"

# Make the image

mkdir -p isodir/boot/grub
cp "${BINARY}" isodir/boot
cp "grub.cfg" isodir/boot/grub/grub.cfg
grub-mkrescue -o "$IMAGE" isodir

# shellcheck disable=SC2154
echo -e "${Green}Created ${IMAGE}${NC}"
