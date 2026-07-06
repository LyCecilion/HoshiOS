bits 32

global kernel_entry
extern kernel_main
extern __bss_start
extern __bss_end

section .text.kernel_entry
kernel_entry:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000
    mov ebp, 0

    mov edi, __bss_start
    mov ecx, __bss_end
    sub ecx, edi
    xor eax, eax
    cld
    rep stosb

    call kernel_main

.halt:
    hlt
    jmp .halt
