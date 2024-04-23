#pragma once

#include "../include/c_stdint.h"

#define _ST2_DISK_RETR_CNT 3

typedef struct
{
    uint8_t         id;
    uint16_t        cylinders;
    uint16_t        sectors;
    uint16_t        heads;
} disk_t;

bool disk_init ( disk_t * disk, uint8_t drive_number );
bool disk_read_sectors ( disk_t * disk, uint32_t lba, uint8_t sectors, uint8_t __far * data_out );
