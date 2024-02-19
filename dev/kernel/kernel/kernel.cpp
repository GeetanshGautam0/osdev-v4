#include "../include/kernel/tty.hpp"
#include "../include/kernel/idt.h"
#include "../include/kernel/pic.h"
#include "../../libc/include/stdio.h"

extern "C"
void kernel_main
( void ) {
    KernelTerminal.init(VGA_COLOR::LIGHT_GREY, VGA_COLOR::BLUE, (dimensions_t){80, 25});
    KernelTerminal.ClearScreen();
    puts("Hello, Kernel!");

#ifdef __i386__
    puts("\tCOMPILED FOR i386 ARCHITECTURE");
    idt_initialize();
    pic_initialize();
    puts("\tInitialized PIC and IDT");
#elif defined(__x86_64__)
    puts("\tCOMPILED FOR x86_64 ARCHITECTURE");
#else
    KernelTerminal.SetColor(VGA_COLOR::WHITE, VGA_COLOR::RED, true);
    KernelTerminal.Write("Unknown architecture.\n\r");
#endif

    printf("TESTING printf: %d-%b-%X-%x-%c\n\r", 1, true, 843830, 0b100101010101011, 0x7B);

}
