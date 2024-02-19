#include "../include/stdio.h"
#include "../../kernel/include/kernel/tty.hpp"
#include "../../kernel/include/kernel/kernel_pol.h"


int
putchar
( int ic )
{

    uintmax_t iter = 0;

    while (!KernelTerminal.Ready() && (++iter) < MAX_ITER);
    if (!KernelTerminal.Ready()) return -1;

    char c = (char) ic;

    KernelTerminal.Write_sz(&c, sizeof(c));
    return ic;

}

