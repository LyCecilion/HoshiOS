ENTRY(kernel_entry)

SECTIONS
{
    . = 0x1000;

    .text : ALIGN(4)
    {
        KEEP(*(.text.kernel_entry))
        *(.text .text.*)
    }

    .rodata : ALIGN(4)
    {
        *(.rodata .rodata.*)
    }

    .data : ALIGN(4)
    {
        *(.data .data.*)
    }

    .bss : ALIGN(4)
    {
        __bss_start = .;
        *(COMMON)
        *(.bss .bss.*)
        __bss_end = .;
    }
}
