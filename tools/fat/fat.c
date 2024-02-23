#include <ctype.h>
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>


typedef struct {
    uint8_t     boot_jump_instruction [3];

    /* FAT12 Header */

    uint8_t     oem_identifier [8];
    uint16_t    bytes_per_sector;
    uint8_t     sectors_per_cluster;
    uint16_t    reserved_sectors;
    uint8_t     fat_count;
    uint16_t    dir_entries_count;
    uint16_t    total_sectors;
    uint8_t     media_desc_type;
    uint16_t    sectors_per_fat;
    uint16_t    sectors_per_track;
    uint16_t    heads;
    uint32_t    hidden_sectors;
    uint32_t    large_sector_count;

    /* Extended Boot Record */

    uint8_t     drive_number;
    uint8_t     _reserved;
    uint8_t     signature;
    uint32_t    volume_id;
    uint8_t     volume_label[11];
    uint8_t     system_id[8];

} __attribute__((packed)) BootSector;


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

} __attribute__((packed)) DirectoryEntry;


BootSector g_boot_sector;
DirectoryEntry * g_root_directory = NULL;
uint32_t g_root_directory_end;


bool read_boot_sector ( FILE* disk )
{
     return fread(&g_boot_sector, sizeof(g_boot_sector), 1, disk) > 0;
}


bool read_sectors ( FILE* disk, uint32_t lba, uint32_t count, void * buffer_out )
{
    bool o = true;
    o &= (fseek(disk, lba * g_boot_sector.bytes_per_sector, SEEK_SET) == 0);
    o &= (fread(buffer_out, g_boot_sector.bytes_per_sector, count, disk) == count);

    return o;
}


uint8_t * g_FAT = NULL;

bool read_FAT ( FILE * disk )
{
    g_FAT = (uint8_t *) malloc(g_boot_sector.sectors_per_fat * g_boot_sector.bytes_per_sector);
    return read_sectors(disk, g_boot_sector.reserved_sectors, g_boot_sector.sectors_per_fat, g_FAT);
}


bool read_root_directory ( FILE * disk )
{

    uint32_t lba = g_boot_sector.reserved_sectors + g_boot_sector.sectors_per_fat * g_boot_sector.fat_count;
    uint32_t size = sizeof(DirectoryEntry) * g_boot_sector.dir_entries_count;
    uint32_t sectors = ( size / g_boot_sector.bytes_per_sector );

    if ( size % g_boot_sector.bytes_per_sector > 0 )
        ++sectors;

    g_root_directory_end = lba + sectors;
    g_root_directory = (DirectoryEntry *) malloc( sectors * g_boot_sector.bytes_per_sector );
    return read_sectors(disk, lba, sectors, g_root_directory);

}


DirectoryEntry * find_file
        ( const char * name )
{

    for ( uint32_t i = 0; i < g_boot_sector.dir_entries_count; i++ )
        if (memcmp(name, g_root_directory[i].name, 11) == 0)
            return &g_root_directory[i];

    return NULL;

}


bool read_file
        ( DirectoryEntry * entry, FILE * disk, uint8_t * output_buffer )
{

    bool o = true;
    uint16_t current_cluster = entry->first_cluster_low;

    do {

        uint32_t lba = g_root_directory_end + ( current_cluster - 2 ) * g_boot_sector.sectors_per_cluster;
        o &= read_sectors( disk, lba, g_boot_sector.sectors_per_cluster, output_buffer );

        output_buffer += g_boot_sector.sectors_per_cluster * g_boot_sector.bytes_per_sector;

        uint32_t fat_index = current_cluster * 3 / 2;
        if (current_cluster % 2 == 0)
            current_cluster = (*(uint16_t *)(g_FAT + fat_index)) & 0x0FFF;
        else
            current_cluster = (*(uint16_t *)(g_FAT + fat_index)) >> 4;

    } while (o && current_cluster < 0x0FF8);

    return o;

}


int main ( int argc, char ** argv )
{

    if ( argc < 3 )
    {
        printf("Syntax: %s <disk name> <file name>\n", argv[0]);
        return -1;
    }

    FILE* disk = fopen(argv[1], "rb");

    if (!disk)
    {
        fprintf(stderr, "Cannot open disk image %s.\n", argv[1]);
        return -1;
    }

    if (!read_boot_sector(disk))
    {
        fprintf(stderr, "Could not read boot sector.\n");
        return -2;
    }

    if (!read_FAT(disk))
    {
        free(g_FAT);

        fprintf(stderr, "Could not read FAT.\n");
        return -3;

    }

    if (!read_root_directory(disk))
    {
        free(g_FAT);
        free(g_root_directory);
        fprintf(stderr, "Could not read root dir.\n");
        return -4;
    }

    DirectoryEntry * file_entry = find_file(argv[2]);
    if (!file_entry)
    {
        free(g_FAT);
        free(g_root_directory);
        fprintf(stderr, "Could not find file \"%s\".\n", argv[2]);
        return -5;
    }

    uint8_t * buffer = (uint8_t *) malloc(file_entry->size + g_boot_sector.bytes_per_sector);
    if (!read_file(file_entry, disk, buffer))
    {
        free(buffer);
        free(g_FAT);
        free(g_root_directory);
        fprintf(stderr, "Could not read file \"%s\".\n", argv[2]);
        return -6;
    }

    for (size_t i = 0; i < file_entry->size; i++)
    {
        if (isprint(buffer[i])) fputc(buffer[i], stdout);
        else printf("<%02x>", buffer[i]);
    }

    printf("\n");

    free(g_root_directory);
    free(g_FAT);
    return 0;

}

