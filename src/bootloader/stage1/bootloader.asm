; for nasm
; * LEGACY MODE

org     0x7C00                      ; In legacy mode, the bootloader must begin at this address
bits    16                          ; Always start in 16-bit mode (the assembler expects 16-bit code)


; FAT12 header
jmp short _boot_os
nop

bdb_oem:                    db 'MSWIN4.1'       ; 8 Bytes indicating OEM. Set to MSWIN4.1 for maximum compatability
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0x0E0
bdb_total_sectors:          dw 2880             ; 2880 * 512 = 1.44 MB
bdb_media_desc_type:        db 0x0F0            ; F0 = 3.5" floppy disk
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dd 0
bdb_large_sector_count:     dd 0

; Extended boot record
ebr_drive_number:           db 0                ; 0x00 floppy, 0x80 hdd
                            db 0                ; reserved
ebr_signature:              db 0x29
ebr_volume_id:              db 0x12, 0x24, 0x56, 0x78       ; Serial number, value doesn't matter
ebr_volume_label:           db 'GGOS       '    ; 11 bytes, padded w/ spaces
ebr_system_id:              db 'FAT12   '       ; 8 bytes, padded w/ spaces

; Code begins

_boot_os:
    jmp main

; ----------------------------------------------------------------------------------------------------------------------
;                                           NO NEW CODE ABOVE THIS POINT
; ----------------------------------------------------------------------------------------------------------------------


%include "src/helper/puts.ASM_HELPER"       ; Import the contents of the helper script puts.ASM_HELPER, which includes the
                                            ;       puts function and the ENDL macro.
%include "src/helper/disk.ASM_HELPER"       ; Import the contents of the helper script disk.ASM_HELPER, which includes the
                                            ;       lab_to_chs, disk_read, and disk_reset routines.
                                            ;       REQUISITES: disk_read_failure is defined as a label in this file.
%include "src/helper/rset.ASM_HELPER"       ; Import the contents of the helper script rset.ASM_HELPER, which includes the
                                            ;       routine wait_key_and_reboot.
                                            ;       See script for REQUISITES and ASSUMPTIONS
;
; Error Handlers
;

disk_read_failure:                          ; Error handler for failure mode of disk_read
    mov si, msg_dr_fail                     ; Load an error message
    call puts                               ; Print the message
    ; If the disk read fails, you ain't finging no stage2.

stage2_not_found:
    mov si, msg_no_stage2                   ; Load error message for not finding STAGE2.BIN
    call puts

;
; Halt routine
;

halt:
    cli                                     ; Disable interrupts so CPU can't escape the "halt" instruction ahead.
    hlt

;
; Main routine
;


main:

    ; Setup the data segments, moving 0 into all of them
    mov ax, 0
    mov ds, ax
    mov es, ax

    ; Setup the stack
    mov ss, ax
    mov sp, 0x7C00                  ; This is the top of the stack, the stack will load downward from here (i.e., toward 0x00000
                                    ; This ensures that the stack does not write to the area of memory containing the operating system
                                    ;       as the OS starts at 0x7C00 (see the org directive at the top of the file)

    push es
    push word .after                ; Push the address of .after into the stack and call retf (which "returns" to the last address on stack)
    retf

.after:
    ; Print initial message
    mov si, msg_hello               ; Move the address of the message into the SI register
                                    ;       (DS = 0 => DS:SI = 0:SI => Memory: 16 * segment DS + offset SI = offset = SI)
    call puts


    ; BIOS should set DL to drive number
    ; mov [ebr_drive_number], dl      ; The field ebr_drive_number is useless so we can use its memory space as an optimization.

    ; read drive parameters (sectors per track and head count),
    ; instead of relying on data on formatted disk
    push es
    mov ah, 0x08
    int 0x13
    jc disk_read_failure
    pop es

    and cl, 0x3F                        ; remove top 2 bits
    xor ch, ch
    mov [bdb_sectors_per_track], cx     ; sector count

    inc dh
    mov [bdb_heads], dh                 ; head count

    ; Read the root directory. Note: using FAT 12 file system.
    ; Compute LBA of root dir = reserved + fats * sectors_per_fat

    mov ax, [bdb_sectors_per_fat]   ; ax: sectors per fat
    mov bl, [bdb_fat_count]         ; bl: fat count
    xor bh, bh                      ; bh: 0
    mul bx                          ; ax: bx * ax = fat count * sectors per fat
    add ax, [bdb_reserved_sectors]  ; ax: reserved + fats * sectors_per_fat = LBA
    push ax                         ; Push the LBA onto the stack

    ; Compute the size of the root directory = (32 * number of entries) / bytes_per_secctor
    mov ax, [bdb_sectors_per_fat]   ; ax: sectors per fat
    shl ax, 5                       ; ax *= 32
    xor dx, dx                      ; dx = 0
    div word [bdb_bytes_per_sector] ; number of sectors we need to read

    test dx, dx                     ; if dx != 0, add 1
    jz .read_root_dir
    inc ax                          ; division remainder != 0; add 1
                                    ;       this means we have a sector only partially filled with entries

.read_root_dir:

    ; Call disk_read to read the root directory
    mov cl, al                      ; cl: Number of sectors to read = size of root dir
    pop ax                          ; ax: LBA (see push instruction in main.root_dir)
    mov dl, [ebr_drive_number]      ; dl: drive number (saved it previously in main.after)
    mov bx, buffer                  ; ex:bx: Data should be loaded into mem after bootloader (at the buffer label)

    call disk_read                  ; Call the function

.find_stage2_bin:
    ; use bx to count the number of directories checked
    ;     di to point to the current directory entry

    xor bx, bx                      ; bx = 0
    mov di, buffer                  ; di should start at at the first entry read (start of buffer)

.search_kb:

    mov si, file_stage2_bin         ; si: expected file name of STAGE2.BIN
    mov cx, 11                      ; cx: compare upto 11 characters of the name

    push di                         ; save the current value of di
    repe cmpsb                      ; Repeat - compare string bytes
    pop di                          ; Restore pointer

    je .stage2_found                ; If the strings are equal, jump to the stage2_found label
    add di, 32                      ; di += 32; 32 is the size of one directory entry -> di => next entry
    inc bx                          ; Increment the number of directory entries checked
    cmp bx, [bdb_dir_entries_count] ; Check to see if there are more entries to check

    jl .search_kb                   ; If there are more entries to check (bx < dir entries count), loop
    jmp stage2_not_found            ; Jump to error message.

.stage2_found:

    ; di should have the address to the entry
    mov ax, [di + 26]               ; First logical cluster field (offset 26)
    mov [stage2_cluster], ax         ; Save the above value to the stage2_cluster field

    ; load FAT from disk into memory
    mov ax, [bdb_reserved_sectors]
    mov bx, buffer
    mov cl, [bdb_sectors_per_fat]
    mov dl, [ebr_drive_number]

    call disk_read

    ; Read stage2 and process FAT chain
    ; REFER TO THE REAL MODE ADDRESS SPACE (THE FIRST MiB)
    ;       0x0000:0x7E00 -> 0x0000:0x7FFFF is the available for use and is the largest contiguous
    ;       usable region of memory in this mode. More memory will become accessible in 32-bit protected mode

    ; Leaving some room for the FAT, using address 0x0000:0x2000 to store the data to (~380 KiB).

    mov bx, stage2_LOAD_SEGMENT
    mov es, bx
    mov bx, stage2_LOAD_OFFSET

    ; es:bs = stage2_LOAD_SEGMENT:stage2_LOAD_OFFSET

.load_stage2_loop:

    ; Read next cluster
    mov ax, [stage2_cluster]
    ; TODO: Fix this magic number. This will only work for a 1.44M floppy disk.
    add ax, 31                      ; First cluster = (stage2 cluster - 2) * sectors per cluster + start sector
                                    ; start sector = reserved + fats + root directory size

    mov cl, 1
    mov dl, [ebr_drive_number]
    call disk_read

    ; TODO: Fix this line. The add instruction will lead to an overflow if the STAGE2.BIN file is larger than 64 kilobytes.
    ;       The first part of the loaded stage2 will be overwritten as the address overflows and returns to 0.
    add bx, [bdb_bytes_per_sector]

    ; Compute the location of the next sector
    mov ax, [stage2_cluster]
    mov cx, 3
    mul cx
    mov cx, 2
    div cx                          ; ax = index of entry in FAT, dx = cluster (mod 2)

    mov si, buffer
    add si, ax
    mov ax, [ds:si]                 ; Read from FAT table at index ax

    or dx, dx                       ; Will set the zero flag if relevant
    jz .even

.odd:
    shr ax, 4                       ; Div 16
    jmp .next_cluster_after

.even:
    and ax, 0x0FFF

.next_cluster_after:
    cmp ax, 0x0FF8                  ; If ax > 0xFF8, end of chain
    jae .read_finish

    mov [stage2_cluster], ax
    jmp .load_stage2_loop

.read_finish:
    ; Jump to stage2

    mov dl, [ebr_drive_number]      ; boot device in dl
    mov ax, stage2_LOAD_SEGMENT     ; set segment registers
    mov ds, ax
    mov es, ax

    ; Far jump to the stage2
    jmp stage2_LOAD_SEGMENT:stage2_LOAD_OFFSET
    jmp .done                       ; should never happen

.done:

    jmp wait_key_and_reboot
    jmp halt                        ; should never happen


msg_hello:      db '[M] B', ENDL                        ; Boot
msg_dr_fail:    db '[FATAL] E1', ENDL                   ; E1: Disk read failure
msg_no_stage2:  db '[FATAL] E2', ENDL                   ; E2: STAGE2.BIN not found

file_stage2_bin:db 'STAGE2  BIN'    ; Name of stage2.bin file in the expected (FAT 12) format.

; The following two variable dictate where in memory the stage2 will be loaded to.
stage2_LOAD_SEGMENT     equ 0x2000
stage2_LOAD_OFFSET      equ 0

stage2_cluster:  dw 0

; ----------------------------------------------------------------------------------------------------------------------
;                                          NO NEW CODE BEYOND THIS POINT
; ----------------------------------------------------------------------------------------------------------------------

times 510-($-$$) db 0               ; Pad the program such that the first sector (512 bytes), minus the two magic bytes
                                    ;   is filled.

dw 0xAA55                           ; This magic number (2 bytes) is required to let the BIOS know that this is bootloable
                                    ;   code (legacy mode).

buffer:
