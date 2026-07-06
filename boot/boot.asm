; HoshiOS BIOS boot sector.
; Loads a fixed-size kernel image to 0x1000, enters protected mode, then jumps there.

bits 16
org 0x7C00

KERNEL_LOAD_SEG equ 0x0000
KERNEL_LOAD_OFF equ 0x1000
KERNEL_LBA      equ 1
KERNEL_SECTORS  equ 32

CODE_SEL equ 0x08
DATA_SEL equ 0x10

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov [boot_drive], dl

    mov si, boot_msg
    call print_string

    call load_kernel
    call enter_protected_mode

.hang:
    hlt
    jmp .hang

print_string:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    jmp print_string
.done:
    ret

load_kernel:
    mov si, dap
    mov ah, 0x42
    mov dl, [boot_drive]
    int 0x13
    jc disk_error
    ret

disk_error:
    mov si, disk_error_msg
    call print_string
.hang:
    hlt
    jmp .hang

enter_protected_mode:
    lgdt [gdt_descriptor]

    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    jmp CODE_SEL:protected_mode

bits 32
protected_mode:
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    jmp CODE_SEL:KERNEL_LOAD_OFF

bits 16

boot_drive:
    db 0

boot_msg:
    db "HoshiOS boot sector", 13, 10, 0

disk_error_msg:
    db "Disk read failed", 13, 10, 0

align 4
dap:
    db 0x10
    db 0
    dw KERNEL_SECTORS
    dw KERNEL_LOAD_OFF
    dw KERNEL_LOAD_SEG
    dq KERNEL_LBA

align 8
gdt_start:
gdt_null:
    dq 0
gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

times 510 - ($ - $$) db 0
dw 0xAA55
