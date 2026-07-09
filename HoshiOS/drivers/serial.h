#ifndef HOSHIOS_DRIVERS_SERIAL_H
#define HOSHIOS_DRIVERS_SERIAL_H

#include <stdbool.h>

bool serial_init(void);
void serial_putc(char ch);
void serial_write(const char *text);
void serial_writeln(const char *text);

#endif
