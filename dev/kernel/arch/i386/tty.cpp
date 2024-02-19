#include "../../include/kernel/tty.hpp"
#include "../../../libc/include/string.h"

static tty_status_t output_v;
volatile uint16_t * const VGA_MEMORY = (uint16_t *) 0xB8000;

TTY::TTY(
    enum VGA_COLOR  fg,
    enum VGA_COLOR  bg,
    dimensions_t    bounds
) {

    if (tty_status == TTY_STATUS_HALT) return;

    if (!bounds.width || !bounds.height)
        return;

    tty_dim = bounds;
    tty_color = vga_color(fg, bg);
    tty_cursor = (point_t){0, 0};
    tty_buffer = (uint16_t *) VGA_MEMORY;

    tty_status = TTY_STATUS_READY;
    ClearScreen();

}

TTY::~TTY
( void ) {
    tty_status = TTY_STATUS_HALT;
    return;
}

static vga_entry_t _tty_clear_empty_entry;

bool
TTY::_ready
( void ) {
    return tty_status == TTY_STATUS_READY;
}

tty_status_t
TTY::_replace_col
(
        vga_color_t c
) {

    // For each terminal entry, (* = color data, # = character data)
    // ********########
    // ^^^^^^^^     Replace these bits to change the color.

    for ( size_t x = 0; x < tty_dim.width; x++ )
        for ( size_t y = 0; y < tty_dim.height; y++ )
            tty_buffer[ y * tty_dim.width + x ] = (uint16_t)(
                    (tty_buffer[ y * tty_dim.width + x ] & (uint16_t)0b0000000011111111) |
                    c << 8
            );

    return TTY_STATUS_OK;

}

tty_status_t
TTY::SetColor (
        enum VGA_COLOR fg,
        enum VGA_COLOR bg
) {

    if (!_ready()) return TTY_STATUS_NOT_READY;
    tty_status = TTY_STATUS_NOT_READY;

    tty_color = vga_color(fg, bg);
    output_v = _replace_col(tty_color);

    tty_status = TTY_STATUS_READY;
    return output_v;

}

tty_status_t
TTY::SetColor (
        enum VGA_COLOR fg,
        enum VGA_COLOR bg,
        bool clear
) {

    if (!_ready()) return TTY_STATUS_NOT_READY;

    tty_color = vga_color(fg, bg);

    if (clear)
        return ClearScreen();
    else
    {
        tty_status = TTY_STATUS_NOT_READY;

        tty_color = vga_color(fg, bg);
        output_v = _replace_col(tty_color);

        tty_status = TTY_STATUS_READY;
        return output_v;
    }

}

tty_status_t
TTY::ClearScreen
( void ) {

    if (!_ready()) return TTY_STATUS_NOT_READY;
    tty_status = TTY_STATUS_NOT_READY;

    output_v = _clear();
    tty_cursor = (point_t){0, 0};

    tty_status = TTY_STATUS_READY;
    return output_v;

}

tty_status_t
TTY::_clear
( void ) {
    _tty_clear_empty_entry = vga_entry(' ', tty_color);

    for ( size_t xi = 0; xi < tty_dim.width; xi++ )
        for ( size_t yi = 0; yi < tty_dim.height; yi++ )
            tty_buffer[ yi * tty_dim.width + xi ] = _tty_clear_empty_entry;

    return TTY_STATUS_OK;

}

tty_status_t
TTY::_limit_cur
(void) {

    if (tty_cursor.X >= tty_dim.width)
    {

        if (tty_wrap & WRAP_H)
        {
            tty_cursor.X = 0;
            tty_cursor.Y++;
        }
        else
            tty_cursor.X = tty_dim.width - 1;
    }

    if (tty_cursor.Y >= tty_dim.height)
    {
        if (tty_wrap & WRAP_V)
            tty_cursor.Y = 0;
        else
            tty_cursor.Y = tty_dim.height - 1;
    }

    return TTY_STATUS_OK;

}

point_t
TTY::Cursor
( void ) {
    return tty_cursor;
}

tty_status_t
TTY::Cursor
(
        size_t x,
        size_t y
) {
    if (!_ready()) return TTY_STATUS_NOT_READY;
    tty_cursor = (point_t){x, y};

    return TTY_STATUS_OK;
}

tty_status_t
TTY::_put_char
(
        vga_entry_t e,
        size_t x,
        size_t y
) {

    const size_t index = y * tty_dim.width + x;
    tty_buffer[index] = e;

    return TTY_STATUS_OK;

}

tty_status_t
TTY::PutChar
(
    unsigned char uc
) {

    if (!_ready()) return TTY_STATUS_NOT_READY;
    tty_status = TTY_STATUS_NOT_READY;

    output_v = _put_char( vga_entry(uc, tty_color), tty_cursor.X, tty_cursor.Y );
    tty_cursor.X++;

    _limit_cur();

    tty_status = TTY_STATUS_READY;
    return output_v;

}

tty_status_t
TTY::PutChar
(
        unsigned char uc,
        size_t x,
        size_t y,
        bool move_cur
) {

    // Check X and Y
    if (x >= tty_dim.width || y >= tty_dim.height) return TTY_STATUS_ERR;

    if (!_ready()) return TTY_STATUS_NOT_READY;
    tty_status = TTY_STATUS_NOT_READY;

    output_v = _put_char( vga_entry(uc, tty_color), x, y );

    if (move_cur && output_v == TTY_STATUS_OK)
    {
        tty_cursor = (point_t){x + 1, y};
        _limit_cur();
    }

    tty_status = TTY_STATUS_READY;
    return output_v;

}


tty_status_t
TTY::Write_sz
(
        const char * string,
        size_t size
) {

    if (!_ready()) return TTY_STATUS_NOT_READY;
    tty_status = TTY_STATUS_NOT_READY;

    for ( size_t i = 0; i < size; i++ )
    {

        _put_char(vga_entry( string[i], tty_color ), tty_cursor.X + i, tty_cursor.Y);

    }

    if ( tty_cursor.X + size >= tty_dim.width )
    {
        tty_cursor.X += (size_t)(size % tty_dim.width);
        tty_cursor.Y += (unsigned int)(size / tty_dim.width);
    } else
    {
        tty_cursor.X += size;
    }

    _limit_cur();

    tty_status = TTY_STATUS_READY;
    return output_v;

}

tty_status_t
TTY::Write
(
        const char * string
) {

    return Write_sz( string, strlen(string) );

}

