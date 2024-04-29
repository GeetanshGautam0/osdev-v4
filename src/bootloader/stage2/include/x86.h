#include "c_stdint.h"

void _cdecl x86_64_WriteCharTeletype ( char c, uint8_t page );
void _cdecl x86_div64_32(uint64_t dividend, uint32_t divisor, uint64_t* quotientOut, uint32_t* remainderOut);

bool _cdecl x86_disk_reset( uint8_t drive );
bool _cdecl x86_disk_read(
        uint8_t drive,
        uint16_t c,
        uint16_t h,
        uint16_t s,
        uint8_t count,
        uint8_t __far * data_out
);
bool _cdecl x86_disk_get_drive_params(
        uint8_t drive,
        uint8_t * drive_type_out,
        uint16_t * cylinders_out,
        uint16_t * sectors_out,
        uint16_t * heads_out
);
