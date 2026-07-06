#ifndef HOSHIOS_DRIVERS_VGA_H
#define HOSHIOS_DRIVERS_VGA_H

#include <stdint.h>

void vga_clear(void);
void vga_set_color(uint8_t foreground, uint8_t background);
void vga_putc(char ch);
void vga_write(const char *text);
void vga_writeln(const char *text);

#endif
