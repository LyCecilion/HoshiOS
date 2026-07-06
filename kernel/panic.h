#ifndef HOSHIOS_KERNEL_PANIC_H
#define HOSHIOS_KERNEL_PANIC_H

__attribute__((noreturn)) void panic(const char *message);

#endif
