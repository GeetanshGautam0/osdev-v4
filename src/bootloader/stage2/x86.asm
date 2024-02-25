bits 16

section _TEST class=CODE

;
; void _cdecl x86_div64_32(uint64_t dividend, uint32_t divisor, uint64_t* quotientOut, uint32_t* remainderOut);
;                           ^ eax               ^ ecx
;
global _x86_div64_32
_x86_div64_32:

    ; make new call frame
    push bp             ; save old call frame
    mov bp, sp          ; initialize new call frame

    push bx

    ; ----------------------------- x86 DIV -------------------------

    ; Divide upper 32 bits of the divided
    mov eax, [bp + 8]   ; eax = upper 32 bits of dividend (dividend >> 8) & 0xFF
    mov ecx, [bp + 12]  ; ecx = divisor
    xor edx, edx        ; edx = 0
    div ecx             ; eax = divided/divisor, edx dividend (mod divisor)

    ; store upper 32 bits of quotient
    mov bx, [bp + 16]
    mov [bx + 4], eax

    ; divide lower 32 bits
    mov eax, [bp + 4]   ; eax <- lower 32 bits of dividend
                        ; edx <- old remainder
    div ecx

    ; store results
    mov [bx], eax
    mov bx, [bp + 18]
    mov [bx], edx

    ; ----------------------------- x86 DIV -------------------------

    ; restore bx
    pop bx

    ; restore old call frame
    mov sp, bp
    pop bp
    ret

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
