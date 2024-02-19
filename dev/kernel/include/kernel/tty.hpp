#ifndef _KERNEL_TTY_HPP
#define _KERNEL_TTY_HPP 1

#include <stdint.h>
#include <stddef.h>

#include "vga.h"

typedef struct {
    size_t width;
    size_t height;
} dimensions_t;

typedef struct {
    size_t X;
    size_t Y;
} point_t;

typedef unsigned char tty_status_t;
typedef unsigned char tty_wrap_mode_t;

#define TTY_STATUS_NOT_READY    (tty_status_t)4
#define TTY_STATUS_READY        (tty_status_t)3
#define TTY_STATUS_HALT         (tty_status_t)2
#define TTY_STATUS_OK           (tty_status_t)1
#define TTY_STATUS_ERR          (tty_status_t)0

#define WRAP_H                  0b01
#define WRAP_V                  0b10

class TTY
{

public:

    /* Class constructor and destructor */
    TTY     ( enum VGA_COLOR fg, enum VGA_COLOR bg, dimensions_t dimensions );
    ~TTY    ( void );

    /* Public TTY functions */
    tty_status_t        ClearScreen ( void );
    tty_status_t        SetColor    ( enum VGA_COLOR fg, enum VGA_COLOR bg );               // Replaces color
    tty_status_t        SetColor    ( enum VGA_COLOR fg, enum VGA_COLOR bg, bool clear);    // Optionally calls clear screen
    tty_status_t        PutChar     ( unsigned char uc );                                   // Puts char at cursor pos
    tty_status_t        PutChar     ( unsigned char uc, size_t x, size_t y, bool move_cur); // Puts char a (x, y) and optionally moves the cursor.
    tty_status_t        Write_sz    ( const char * string, size_t size);
    tty_status_t        Write       ( const char * string);
    point_t             Cursor      ( void );
    tty_status_t        Cursor      ( size_t x, size_t y );

private:

    /* Private class variables */
    vga_color_t tty_color;
    point_t tty_cursor;
    dimensions_t tty_dim;
    tty_wrap_mode_t tty_wrap = WRAP_H | WRAP_V; // Wrap in both X and Y directions.
    tty_status_t tty_status = 0;

    uint16_t * tty_buffer;

    /* Private TTY functions */
    bool            _ready      ( void );
    tty_status_t    _limit_cur  ( void );
    tty_status_t    _clear      ( void );
    tty_status_t    _put_char   ( vga_entry_t e, size_t x, size_t y, unsigned char c, bool mc );
    tty_status_t    _replace_col( vga_color_t c);
    void            _increment_cursor ( size_t indices );

};


#endif /* _KERNEL_TTY_HPP */
