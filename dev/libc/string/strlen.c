#include "../include/string.h"

static size_t i;
size_t
strlen
(
    const char * string
) {

    i = 0;

    while (string[i])
        ++i;

    return i;

}
