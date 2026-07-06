# HoshiOS

HoshiOS is a small x86 32-bit toy operating system project. The current goal is
to reach two early milestones:

- `v0.0 First Light`: boot with QEMU and print text.
- `v0.1 Debuggable Kernel`: keep kernel symbols and support GDB debugging.

This is not a complete OS. It is a compact BIOS legacy boot + freestanding C
kernel scaffold intended for learning and extension.

## Current Features

- BIOS legacy boot from a handwritten 512-byte boot sector.
- NASM bootloader that loads the kernel from disk into physical address `0x1000`.
- Minimal GDT and switch to 32-bit protected mode.
- Freestanding C11 kernel built with Clang and linked with LLD.
- VGA text output.
- COM1 serial output, visible through QEMU `-serial stdio`.
- `panic()` that prints a message and halts.
- Small kernel string/memory helpers: `kstrlen`, `kmemset`, `kmemcpy`.
- Raw disk image boot through QEMU.
- GDB stub workflow with `kernel.elf` symbols.

## Dependencies

Fedora:

```sh
sudo dnf install qemu-system-x86 nasm clang lld llvm gdb make
```

Some Fedora versions package `llvm-objcopy`, `llvm-objdump`, and `llvm-nm`
inside the main `llvm` package. If your distribution splits LLVM tools into
separate packages, install those as well.

Nix users can enter the development shell:

```sh
nix develop
```

If Nix reports that the current directory is not a valid Git repository, use the
path flake form instead:

```sh
nix develop path:$PWD
```

The dev shell includes QEMU, NASM, Clang, LLD, LLVM tools, GDB,
`clang-format`, GNU Make, and coreutils.

## Build

```sh
make
```

The build creates:

- `build/boot.bin`
- `build/kernel.elf`
- `build/kernel.bin`
- `build/hoshios.img`

The boot sector currently loads exactly 32 sectors for the kernel. The Makefile
checks that `kernel.bin` fits in those sectors and fails with a clear error if
it grows too large.

## Run

```sh
make run
```

QEMU boots `build/hoshios.img` as a raw disk image. Serial output is attached to
the terminal through `-serial stdio`.

Expected VGA text:

```text
Booting HoshiOS...
hello, little universe.
```

Expected serial text:

```text
[HoshiOS] serial online
[HoshiOS] entering kernel_main
[HoshiOS] hello from kernel
```

## Debug

Start QEMU with the GDB stub:

```sh
make debug
```

In another terminal:

```sh
gdb -x tools/gdbinit
```

`tools/gdbinit` sets the architecture to `i386`, connects to `:1234`, loads
symbols from `build/kernel.elf`, and sets a breakpoint at `kernel_main`.

Useful follow-up GDB commands:

```gdb
continue
disassemble kernel_main
info registers
```

## Other Make Targets

```sh
make clean
make format
make disasm
make symbols
```

- `make clean` removes `build/`.
- `make format` formats C headers and sources with `clang-format`.
- `make disasm` writes `build/kernel.disasm`.
- `make symbols` writes `build/kernel.symbols`.

## Freestanding C Notes

This kernel is built with `-ffreestanding` and `-fno-builtin`. It does not link
against libc.

Do not include or call:

- `stdio.h`
- `stdlib.h`
- `string.h`
- libc `strlen`
- libc `memset`
- libc `memcpy`

Allowed standard headers in this stage:

- `stdint.h`
- `stddef.h`
- `stdbool.h`
- `stdarg.h`

Use kernel-owned helpers such as `kstrlen`, `kmemset`, and `kmemcpy` when string
or memory operations are needed.

## Current Non-Goals

This stage intentionally does not implement:

- paging
- dynamic memory allocation
- interrupts
- exception handlers
- PIC/APIC setup
- timers
- keyboard input
- filesystems
- processes or threads
- syscalls
- shell
- C++
- GRUB, Limine, or Multiboot
- libc

## Next Stage: v0.2 Interrupt Garden

The next useful milestone is interrupt bring-up:

- Create an IDT.
- Add CPU exception handlers.
- Remap the PIC.
- Add simple IRQ stubs.
- Add timer tick logging.
- Add basic keyboard scancode logging.
- Extend `panic()` with register dumps from exception frames.

Do not add those features until the boot path, serial logging, and GDB workflow
are stable.
