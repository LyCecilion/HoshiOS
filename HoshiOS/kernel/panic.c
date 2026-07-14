#include "kernel/panic.h"

#include "arch/i386/halt.h"
#include "drivers/serial.h"
#include "drivers/vga.h"

void panic(const char *message)
{
    vga_writeln("");
    vga_set_color(0x0C, 0x00);
    vga_write("PANIC: ");
    vga_writeln(message);

    serial_write("[HoshiOS] PANIC: ");
    serial_writeln(message);

    halt_forever();
}
