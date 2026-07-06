#include "drivers/serial.h"

#include <stddef.h>
#include <stdint.h>

#include "arch/i386/port_io.h"

enum
{
    COM1 = 0x3F8,
};

static int serial_received(void)
{
    return inb(COM1 + 5) & 1;
}

static int transmit_empty(void)
{
    return inb(COM1 + 5) & 0x20;
}

bool serial_init(void)
{
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x80);
    outb(COM1 + 0, 0x03);
    outb(COM1 + 1, 0x00);
    outb(COM1 + 3, 0x03);
    outb(COM1 + 2, 0xC7);
    outb(COM1 + 4, 0x0B);

    (void)serial_received();
    return true;
}

void serial_putc(char ch)
{
    while (transmit_empty() == 0)
    {
    }

    outb(COM1, (uint8_t)ch);
}

void serial_write(const char *text)
{
    for (size_t i = 0; text[i] != '\0'; i++)
    {
        if (text[i] == '\n')
        {
            serial_putc('\r');
        }
        serial_putc(text[i]);
    }
}

void serial_writeln(const char *text)
{
    serial_write(text);
    serial_write("\n");
}
