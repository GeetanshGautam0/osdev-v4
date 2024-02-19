#ifndef _KERNEL_VGA_H
#define _KERNEL_VGA_H 1

#if defined(__cplusplus)
extern "C" {
#endif /* __cplusplus */

#include <stddef.h>
#include <stdint.h>

typedef uint8_t vga_color_t;
typedef uint16_t vga_entry_t;

enum VGA_COLOR {
    BLACK = 0,
    BLUE = 1,
    GREEN = 2,
    CYAN = 3,
    RED = 4,
    MAGENTA = 5,
    BROWN = 6,
    LIGHT_GREY = 7,
    DARK_GREY = 8,
    LIGHT_BLUE = 9,
    LIGHT_GREEN = 10,
    LIGHT_CYAN = 11,
    LIGHT_RED = 12,
    LIGHT_MAGENTA = 13,
    LIGHT_BROWN = 14,
    WHITE = 15,
};

static inline vga_color_t
vga_color
        (
                enum VGA_COLOR fg, enum VGA_COLOR bg
        ) {

    return (vga_color_t) (fg | (bg << 4));

}

static inline vga_entry_t
vga_entry
        (
                unsigned char c, vga_color_t color
        ) {

    return (vga_entry_t) ((uint16_t) c | (uint16_t) color << 8);

}

#if defined(__cplusplus)
}
#endif /* __cplusplus */

#endif /* _KERNEL_VGA_H */