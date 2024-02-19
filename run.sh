source consts.sh

check_file "${BINARY}"  # Check to see if the binary exists
$QEMU -kernel "${BINARY}"  # Run
