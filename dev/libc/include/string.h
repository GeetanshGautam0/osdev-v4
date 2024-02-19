#ifndef _LIBC_STRING_H
#define _LIBC_STRING_H 1

#include <stddef.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C" {
#endif /* __cplusplus */

size_t  strlen  ( const char * string_data );
int     memcmp  ( const void*, const void*, size_t );
void*   memcpy  ( void* __restrict, const void* __restrict, size_t );
void*   memmove ( void*, const void*, size_t );
void*   memset  ( void*, int, size_t );


#if defined(__cplusplus)
}
#endif /* __cplusplus */

#endif /* _LIBC_STRING_H */
