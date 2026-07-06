#include "lib/string.h"

size_t kstrlen(const char *text)
{
    size_t length = 0;

    while (text[length] != '\0')
    {
        length++;
    }

    return length;
}

void *kmemset(void *dest, int value, size_t count)
{
    uint8_t *bytes = dest;
    uint8_t byte = (uint8_t)value;

    for (size_t i = 0; i < count; i++)
    {
        bytes[i] = byte;
    }

    return dest;
}

void *kmemcpy(void *dest, const void *src, size_t count)
{
    uint8_t *dest_bytes = dest;
    const uint8_t *src_bytes = src;

    for (size_t i = 0; i < count; i++)
    {
        dest_bytes[i] = src_bytes[i];
    }

    return dest;
}
