#ifndef HOSHIOS_KERNEL_ASSERT_H
#define HOSHIOS_KERNEL_ASSERT_H

#include "kernel/panic.h"

#define STRINGIFY_(x) #x
#define STRINGIFY(x)  STRINGIFY_(x)

#define assert(cond)                                                                               \
    do                                                                                             \
    {                                                                                              \
        if (!(cond))                                                                               \
        {                                                                                          \
            panic("assertion failed: " #cond " at " __FILE__ ":" STRINGIFY(__LINE__));             \
        }                                                                                          \
    } while (0)

#endif
