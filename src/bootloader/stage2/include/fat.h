#pragma once
#include "c_stdint.h"
#include "disk.h"

#ifndef _FAT_H
#define _FAT_H 1

#pragma pack(push, 1)
typedef struct {

    uint8_t     name[11];
    uint8_t     attributes;
    uint8_t     _reserved;
    uint8_t     created_time_tenths;
    uint16_t    created_time;
    uint16_t    created_date;
    uint16_t    accessed_date;
    uint16_t    first_cluster_high;
    uint16_t    modified_time;
    uint16_t    modified_date;
    uint16_t    first_cluster_low;
    uint32_t    size;

} fat_directory_entry_t;
#pragma pack(pop)

typedef struct
{
    int handle;
    bool is_dir;
    uint32_t pos;
    uint32_t size;
} fat_file_t;

enum fat_attributes
{
    FAT_ATTRIBUTE_READ_ONLY         = 0x01,
    FAT_ATTRIBUTE_HIDDEN            = 0x02,
    FAT_ATTRIBUTE_SYSTEM            = 0x04,
    FAT_ATTRIBUTE_VOLUME_ID         = 0x08,
    FAT_ATTRIBUTE_DIRECTORY         = 0x10,
    FAT_ATTRIBUTE_ARCHIVE           = 0x20,
    FAT_ATTRIBUTE_LFN               = FAT_ATTRIBUTE_READ_ONLY | FAT_ATTRIBUTE_HIDDEN | FAT_ATTRIBUTE_SYSTEM | FAT_ATTRIBUTE_VOLUME_ID
};

bool fat_init (disk_t * disk );
fat_file_t __far * fat_open (disk_t * disk, const char * path);
uint32_t fat_read(disk_t * disk, fat_file_t __far * file, uint32_t byte_count, void * data_out);
bool fat_read_entry(disk_t * disk, fat_file_t __far * file, fat_directory_entry_t * entry);
void fat_close(fat_file_t __far * file);

#endif /* _FAT_H */
