source consts.sh

# $1: First arg - source file
# $2: Second arg - dest file
check_file $1
$TARGET-g++ -c $1 -o $2 -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti
