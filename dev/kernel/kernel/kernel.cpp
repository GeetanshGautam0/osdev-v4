#include "../include/kernel/tty.hpp"

extern "C"
void kernel_main
( void ) {

    TTY tty = TTY(VGA_COLOR::LIGHT_GREY, VGA_COLOR::BLUE, (dimensions_t){80, 25});
    tty.ClearScreen();
    tty.Write("Hello, Kernel!\n\r");

#ifdef __i386__
    tty.Write("\tCOMPILED FOR i386 ARCHITECTURE");
#elif defined(__x86_64__)
    tty.Write("\tCOMPILED FOR x86_64 ARCHITECTURE");
#else
    tty.SetColor(VGA_COLOR::WHITE, VGA_COLOR::RED, true);
    tty.Write("Unknown architecture.");
#endif

}
