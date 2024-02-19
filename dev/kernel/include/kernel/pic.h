#ifndef _KERNEL_PIC_H
#define _KERNEL_PIC_H 1

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include <stdint.h>

uint16_t    pic_read_irr    ( void );
uint16_t    pic_read_isr    ( void );

void        pic_eoi_slave   ( void );
void        pic_eoi_master  ( void );
void        pic_initialize  ( void );
void        pic_disable     ( void );

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _KERNEL_PIC_H */