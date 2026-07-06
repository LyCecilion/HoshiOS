#ifndef HOSHIOS_ARCH_I386_HALT_H
#define HOSHIOS_ARCH_I386_HALT_H

__attribute__((noreturn)) static inline void halt_forever(void)
{
    for (;;)
    {
        __asm__ volatile("hlt");
    }
}

#endif
