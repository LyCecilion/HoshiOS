#include "kernel/log.h"

#include "drivers/serial.h"

void log_info(const char *message)
{
    serial_write("[HoshiOS] ");
    serial_writeln(message);
}
