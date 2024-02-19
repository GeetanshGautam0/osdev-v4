#include "../include/kernel/tty.hpp"

extern "C"
void kernel_main
( void ) {

    TTY tty = TTY(VGA_COLOR::WHITE, VGA_COLOR::BLUE, (dimensions_t){80, 25});
    tty.ClearScreen();
    tty.Write("Hello, Kernel!");
    tty.Write("Wow this actually works.");

    tty.SetColor(VGA_COLOR::LIGHT_BROWN, VGA_COLOR::BLACK);

}
