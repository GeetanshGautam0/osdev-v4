#pragma once

#include "c_stdio.h"
#include "fat.h"
#include "disk.h"

#ifndef _ST2_FIO_H
#define _ST2_FIO_H 

#define _ST2_FIO_N_FDE 9

static fat_directory_entry_t _FDE[_ST2_FIO_N_FDE];      // The list of file directory enteries (from load_dir_contents)
static fat_file_t far * _FF = NULL;                     // The file handler from load_file_content is loaded in here

bool load_dir_contents ( disk_t * disk, const char * file_path, unsigned char N );
bool load_file_content ( disk_t * disk, const char * file_path );

bool echo_dir_contents ( disk_t * disk, const char * file_path, int N );
bool echo_file_content ( disk_t * disk, char * buffer, const char * file_path );


#endif /* _ST2_FIO_H */
