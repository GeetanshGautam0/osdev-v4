#include "../include/kernel/tty.hpp"

extern "C"
void kernel_main
( void ) {

    TTY tty = TTY(VGA_COLOR::LIGHT_GREY, VGA_COLOR::BLUE, (dimensions_t){80, 25});
    tty.ClearScreen();
    tty.Write("Hello, Kernel!");

}
