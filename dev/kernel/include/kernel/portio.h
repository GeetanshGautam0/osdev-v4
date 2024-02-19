#ifndef _KERNEL_PORTIO_H
#define _KERNEL_PORTIO_H 1

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#if !(defined(__i386__) || defined(__x86_64__))
#error "PORT IO: Architecture does not have IO ports"
#endif

#include <stdint.h>

__attribute__((unused))
static inline uint8_t outport8(uint16_t port, uint8_t value) {
    asm volatile ("outb %1, %0" : : "dN" (port), "a" (value));
    return value;
}

// Define an alias to outport8 for convenience
__attribute__((unused)) static inline uint8_t outb ( uint16_t port, uint8_t value ) { return outport8(port, value); }

__attribute__((unused))
static inline uint16_t outport16(uint16_t port, uint16_t value) {
    asm volatile ("outw %1, %0" : : "dN" (port), "a" (value));
    return value;
}

__attribute__((unused))
static inline uint32_t outport32(uint16_t port, uint32_t value) {
    asm volatile ("outl %1, %0" : : "dN" (port), "a" (value));
    return value;
}

__attribute__((unused))
static inline uint8_t inport8(uint16_t port) {
    uint8_t result;
    asm volatile("inb %1, %0" : "=a" (result) : "dN" (port));
    return result;
}

// Define an alias to inport8 for convenience
__attribute__((unused)) static inline uint8_t inb( uint16_t port ) { return inport8(port); }

__attribute__((unused))
static inline uint16_t inport16(uint16_t port) {
    uint16_t result;
    asm volatile("inw %1, %0" : "=a" (result) : "dN" (port));
    return result;
}

__attribute__((unused))
static inline uint32_t inport32(uint16_t port) {
    uint32_t result;
    asm volatile("inl %1, %0" : "=a" (result) : "dN" (port));
    return result;
}

__attribute__((unused)) static inline void io_wait ( void ) { outb(0x80, 0); }

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _KERNEL_PORTIO_H */
