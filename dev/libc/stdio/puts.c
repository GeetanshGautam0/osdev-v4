#include "../include/stdio.h"
#include "../../kernel/include/kernel/kernel_pol.h"

int
puts
( const char * string )
{

#if AUTO_CR
    return printf("%s\n", string);
#else
    return printf("%s\n\r", string);
#endif

}
