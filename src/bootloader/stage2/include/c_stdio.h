#ifndef C_STDIO_H
#define C_STDIO_H 1

#define TAB_WIDTH 4

void putc ( char c );
void puts ( const char * s );
void puts_f ( const char __far * s );

void _cdecl printf16 ( const char * __restrict fmt, ... );

#endif /* C_STDIO_H */

