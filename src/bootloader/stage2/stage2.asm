bits 16

section _ENTRY class=CODE

extern _cstart_
global entry

entry:
    mov si, msg_s2e_call
    call puts

    cli                                             ; Interrupts should be disabled while setting up the stack

    ; ds should already be set by stage 1
    mov ax, ds
    mov ss, ax
    mov sp, 0
    mov bp, sp

    sti

    ; EXPECT boot drive in dl, send its argument to cstart function
    xor dh, dh
    push dx

    call _cstart_                                   ; Call the cstart function in stage2.c

    ; The code should never reach this point but out of caution, we'll clear the interrupt flag and
    ; halt the CPU so that the OS hangs if this point is ever reached.
    ;       DO NOT EXPECT THE CPU TO BE IN ANY PARTICULAR STAGE NOW.

    cli
    hlt

%include "src/helper/puts.ASM_HELPER"

msg_s2e_call: db '[S] <S2.ENTRY>: Entered STAGE2 of bootloader.', ENDL
