#include "drivers/vga.h"

#include <stddef.h>
#include <stdint.h>

enum
{
    VGA_WIDTH = 80,
    VGA_HEIGHT = 25,
    VGA_MEMORY = 0xB8000,
};

static size_t row;
static size_t column;
static uint8_t color = 0x0F;
static volatile uint16_t *const buffer = (volatile uint16_t *)VGA_MEMORY;

static uint16_t vga_entry(char ch)
{
    return (uint16_t)((uint16_t)color << 8) | (uint8_t)ch;
}

static void vga_newline(void)
{
    column = 0;
    if (row + 1 < VGA_HEIGHT)
    {
        row++;
    }
}

void vga_clear(void)
{
    for (size_t y = 0; y < VGA_HEIGHT; y++)
    {
        for (size_t x = 0; x < VGA_WIDTH; x++)
        {
            buffer[(y * VGA_WIDTH) + x] = vga_entry(' ');
        }
    }

    row = 0;
    column = 0;
}

void vga_set_color(uint8_t foreground, uint8_t background)
{
    color = (uint8_t)((background << 4) | (foreground & 0x0F));
}

void vga_putc(char ch)
{
    if (ch == '\n')
    {
        vga_newline();
        return;
    }

    buffer[(row * VGA_WIDTH) + column] = vga_entry(ch);

    column++;
    if (column >= VGA_WIDTH)
    {
        vga_newline();
    }
}

void vga_write(const char *text)
{
    for (size_t i = 0; text[i] != '\0'; i++)
    {
        vga_putc(text[i]);
    }
}

void vga_writeln(const char *text)
{
    vga_write(text);
    vga_putc('\n');
}
