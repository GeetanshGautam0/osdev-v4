bits 16

section _TEST class=CODE

; Include the C calling convention macros
%include "src/bootloader/stage2/x86/cdecl.ASM_HELPER"

; Include the functions
%include "src/bootloader/stage2/x86/x86_div.ASM_HELPER"
%include "src/bootloader/stage2/x86/x86_disk.ASM_HELPER"
%include "src/bootloader/stage2/x86/x86_teletype.ASM_HELPER"
