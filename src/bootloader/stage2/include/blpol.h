#pragma once

#ifndef _BOOTLOADER_POLICY_H
#define _BOOTLOADER_POLICY_H 1

#define FAT_SECTOR_SIZE         512             /* Size of one sector per the FAT12 format */
#define FAT_MAX_PATH_SIZE       256             /* Maximum path length */
#define FAT_MAX_DIR_DEPTH       64              /* The maximum depth of nested directories */
#define FAT_MAX_FILE_HANDLES    10              /* The maximum number of file handles that can be opened at once */
#define FAT_ROOT_DIR_HANDLE     -1              /* The pseudo-index handler for the root directory */
#define FAT_NUM_DISKS           16              /* The number of disks that can be mounted */

#define MAX_LOOP_ITER           10000           /* The maximum number of iterations that are allowed by a while loop */

#define FIO_ECHO_FILE_AUTO_CR   0               /* Wheter file_io.echo_file_content should add an NLCR automatically. */
                                                /* By convention, 0 = FALSE (OFF); 1 = TRUE (ON) */

#endif
