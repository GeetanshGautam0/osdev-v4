org 0x0
bits 16

start:
    jmp a_kernel_main

; ----------------------------------------------------------------------------------------------------------------------
;                                           NO NEW CODE ABOVE THIS POINT
; ----------------------------------------------------------------------------------------------------------------------

%include "src/helper/puts.ASM_HELPER"               ; Include the puts helper script. Defines the puts routine and the ENDL macro

a_kernel_main:                                      ; The main function of kernel.bin
    mov si, msg_hello                               ; Move the address of the start of the hello message into the si register
    call puts                                       ; Call the put string routine to inform the user that kernel.bin has been
                                                    ;       found and a_kernel_main has been called.

.halt:
    cli
    hlt

msg_hello: db '[S] <A_KERNEL_MAIN>: KERNEL.BIN found and loaded', ENDL
