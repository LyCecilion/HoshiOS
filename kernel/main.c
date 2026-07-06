#include "drivers/serial.h"
#include "drivers/vga.h"
#include "kernel/log.h"

void kernel_main(void);

void kernel_main(void)
{
    vga_clear();
    vga_writeln("Booting HoshiOS...");
    vga_writeln("hello, little universe.");

    (void)serial_init();
    log_info("serial online");
    log_info("entering kernel_main");
    log_info("hello from kernel");
}
