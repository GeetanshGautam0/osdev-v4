// PIC code was taken from the following repo
//  https://gitlab.com/sortie/myos/-/blob/master/kernel/arch/i386/pic.c

#include "../../../libc/include/sys/cdefs.h"
#include "../../include/kernel/pic.h"
#include "../../include/kernel/portio.h"

const uint16_t PIC_MASTER       = 0x20;
const uint16_t PIC_SLAVE        = 0xA0;
const uint16_t PIC_COMMAND      = 0x00;
const uint16_t PIC_DATA         = 0x01;
const uint8_t PIC_CMD_ENDINTR   = 0x20;             /* Command to end the interrupt (*EOI functions) */
const uint8_t PIC_ICW1_ICW4     = 0x01;
const uint8_t PIC_ICW1_SINGLE   = 0x02;             // Single (cascade) mode
const uint8_t PIC_ICW1_INTERVAL4 = 0x04;            // Call address interval 4 (8)
const uint8_t PIC_ICW1_LEVEL    = 0x08;             // Level triggered (edge) mode
const uint8_t PIC_CMD_INIT      = 0x10;             // Initialize command for PIC
const uint8_t PIC_MODE_8086     = 0x01;             // 8086/88 (MCS-80/85) mode
const uint8_t PIC_MODE_AUTO     = 0x02;             // Auto (normal) EOI
const uint8_t PIC_MODE_BUF_SLAVE = 0x08;            // Buffered mode/slave
const uint8_t PIC_MODE_BUF_MASTER = 0x0C;           // Buffered mode/master
const uint8_t PIC_MODE_SFNM     = 0x10;             // Special fully nested (not)
const uint8_t PIC_READ_IRR      = 0x0A;             /* OCW3 IRQ Ready next CMD read */
const uint8_t PIC_READ_ISR      = 0x0B;             /* OCW3 IRQ Service next CMD read */

/* Helper functions */

static uint16_t
__pic_get_irq_reg ( int ocw3 )
{

    /*
     * OCW3 to PIC CMD to get the register values. PIC2 (slave) is chained, and
     * represents IRQs 8-15. PIC1 (master) is IRQs 0-7 wth 2 being the chain ( IRQ2 not avail to kernel )
     * */

    outb(PIC_MASTER + PIC_COMMAND, ocw3);
    io_wait();
    outb(PIC_SLAVE + PIC_COMMAND, ocw3);
    io_wait();

    return (inb(PIC_SLAVE + PIC_COMMAND) << 8) | inb(PIC_MASTER + PIC_COMMAND);

}

enum PIC_ID { MASTER, SLAVE };

static uint8_t __psc_out;
static uint8_t
__pic_send_command ( enum PIC_ID id, uint8_t command )
{

    __psc_out = 0;

    switch (id)
    {
        case MASTER:
            __psc_out = outb(PIC_MASTER + PIC_COMMAND, command);
            break;

        case SLAVE:
            __psc_out = outb(PIC_SLAVE  + PIC_COMMAND, command);
            break;
    }

    io_wait();
    return __psc_out;

}

static uint8_t __psd_out;
static uint8_t
__pic_send_data ( enum PIC_ID id, uint8_t data )
{

    __psd_out = 0;

    switch (id)
    {
        case MASTER:
            __psd_out = outb(PIC_MASTER + PIC_DATA, data);
            break;

        case SLAVE:
            __psd_out = outb(PIC_SLAVE  + PIC_DATA, data);
            break;
    }

    io_wait();
    return __psd_out;

}


uint16_t pic_read_irr ( void ) /* Interrupt request register */ { return __pic_get_irq_reg(PIC_READ_IRR); }

uint16_t pic_read_isr ( void ) /* In-service register */        { return __pic_get_irq_reg(PIC_READ_ISR); }

void pic_eoi_master
( void ) /* End of interrupt */ { outb(PIC_MASTER, PIC_CMD_ENDINTR); }

void pic_eoi_slave
( void ) /* End of interrupt */ { outb(PIC_SLAVE, PIC_CMD_ENDINTR); }

void pic_disable
( void ) {
    __pic_send_data(MASTER, 0xFF);
    __pic_send_data(SLAVE, 0xFF);
}

void IRQ_set_mask
( uint8_t IRQ_line ) {

    uint16_t port;
    uint8_t value;

    if (IRQ_line < 8)
        port = PIC_MASTER + PIC_DATA;
    else
    {
        port = PIC_SLAVE + PIC_DATA;
        IRQ_line -= 8;
    }

    value = inb(port) | (1 << IRQ_line);
    io_wait();
    outb(port, value);

}

void IRQ_clear_mask
( uint8_t IRQ_line ) {

    uint16_t port;
    uint8_t value;

    if (IRQ_line < 8)
        port = PIC_MASTER + PIC_DATA;
    else
    {
        port = PIC_SLAVE + PIC_DATA;
        IRQ_line -= 8;
    }

    value = inb(port) & ~(1 << IRQ_line);
    io_wait();
    outb(port, value);

}

void pic_initialize
( void ) {

    uint8_t map_irsq_at = 32;
    uint8_t master_mask = 0;
    uint8_t slave_mask  = 0;

    // Init PIC1 and PIC2
    __pic_send_command(MASTER,  PIC_CMD_INIT | PIC_ICW1_ICW4);
    __pic_send_command(SLAVE,   PIC_CMD_INIT | PIC_ICW1_ICW4);

    // Configure PIC1 and PIC2
    __pic_send_data(MASTER,     map_irsq_at + 0);       // Map master to 0-7
    __pic_send_data(SLAVE,      map_irsq_at + 8);       // Map slave to 8-15
    __pic_send_data(MASTER,     0x04);                  // Slave PIC at IRQ2
    __pic_send_data(SLAVE,      0x02);                  // Cascade Identity
    __pic_send_data(MASTER,     PIC_MODE_8086);         // Set to 8086 mode
    __pic_send_data(SLAVE,      PIC_MODE_8086);         // Set to 8086 mode
    __pic_send_data(MASTER,     master_mask);           // Do not mask any interrupts
    __pic_send_data(SLAVE,      slave_mask);            // Do not mask any interrupts

}


/*
 * PIC mappings
 *
 * IRQ1     Keyboard interrupts
 * */

