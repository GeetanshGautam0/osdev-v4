org 0x0
bits 16

start:
    jmp a_bs2_main

; ----------------------------------------------------------------------------------------------------------------------
;                                           NO NEW CODE ABOVE THIS POINT
; ----------------------------------------------------------------------------------------------------------------------

%include "src/helper/puts.ASM_HELPER"               ; Include the puts helper script. Defines the puts routine and the ENDL macro

a_bs2_main:                                         ; The main function of stage2.bin
    mov si, msg_hello                               ; Move the address of the start of the hello message into the si register
    call puts                                       ; Call the put string routine to inform the user that stage2.bin has been
                                                    ;       found and a_bs2_main has been called.

.halt:
    cli
    hlt

msg_hello: db '[S] <A_BS2_MAIN>: STAGE2.BIN found and loaded', ENDL
