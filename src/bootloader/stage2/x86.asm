bits 16

section _TEST class=CODE

;
;   _x86_64_WriteCharTeletype
;   Using:
;       INT 10h with ah = 0Eh
;   Args:
;       character, page
;

global _x86_64_WriteCharTeletype
_x86_64_WriteCharTeletype:

    ; make new call frame
    push bp             ; save old call frame
    mov bp, sp          ; initialize new call frame

    ; save bx
    push bx

    ; [bp + 0] - old call frame
    ; [bp + 2] - return address (small memory model => 2 bytes)
    ; [bp + 4] - first argument (character)
    ; [bp + 6] - second argument (page)
    ; note: bytes are converted to words (you can't push a single byte on the stack)
    mov ah, 0x0E
    mov al, [bp + 4]
    mov bh, [bp + 6]

    int 0x10

    ; restore bx
    pop bx

    ; restore old call frame
    mov sp, bp
    pop bp
    ret
