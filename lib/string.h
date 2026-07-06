#ifndef HOSHIOS_LIB_STRING_H
#define HOSHIOS_LIB_STRING_H

#include <stddef.h>
#include <stdint.h>

size_t kstrlen(const char *text);
void *kmemset(void *dest, int value, size_t count);
void *kmemcpy(void *dest, const void *src, size_t count);

#endif
