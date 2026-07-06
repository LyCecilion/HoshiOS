BUILD_DIR := build

NASM := nasm
CC := clang
LD := ld.lld
OBJCOPY := llvm-objcopy
OBJDUMP := llvm-objdump
NM := llvm-nm
QEMU := qemu-system-i386
CLANG_FORMAT := clang-format

KERNEL_LOAD_ADDR := 0x1000
KERNEL_SECTORS := 32
SECTOR_SIZE := 512
KERNEL_MAX_BYTES := $(shell expr $(KERNEL_SECTORS) \* $(SECTOR_SIZE))

CFLAGS := \
	--target=i386-elf \
	-std=c11 \
	-ffreestanding \
	-fno-builtin \
	-fno-stack-protector \
	-fno-pic \
	-m32 \
	-Wall \
	-Wextra \
	-Wpedantic \
	-Wshadow \
	-Wconversion \
	-Wsign-conversion \
	-Wmissing-prototypes \
	-Wstrict-prototypes \
	-I.

ASFLAGS_KERNEL := -f elf32
LDFLAGS := -T linker.ld -nostdlib -static

BOOT_BIN := $(BUILD_DIR)/boot.bin
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
KERNEL_PADDED := $(BUILD_DIR)/kernel.padded.bin
IMAGE := $(BUILD_DIR)/hoshios.img
DISASM := $(BUILD_DIR)/kernel.disasm
SYMBOLS := $(BUILD_DIR)/kernel.symbols

C_SOURCES := \
	kernel/main.c \
	kernel/panic.c \
	kernel/log.c \
	drivers/vga.c \
	drivers/serial.c \
	lib/string.c

ASM_SOURCES := boot/kernel_entry.asm

C_OBJECTS := $(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SOURCES))
ASM_OBJECTS := $(patsubst %.asm,$(BUILD_DIR)/%.o,$(ASM_SOURCES))
OBJECTS := $(ASM_OBJECTS) $(C_OBJECTS)

FORMAT_FILES := $(C_SOURCES) \
	kernel/panic.h \
	kernel/log.h \
	drivers/vga.h \
	drivers/serial.h \
	arch/i386/port_io.h \
	arch/i386/halt.h \
	lib/string.h

.PHONY: all run debug clean format disasm symbols check-kernel-size

all: $(IMAGE)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT_BIN): boot/boot.asm | $(BUILD_DIR)
	$(NASM) -f bin -o $@ $<
	@test "$$(wc -c < $@)" -eq $(SECTOR_SIZE) || \
		(echo "error: boot sector must be exactly $(SECTOR_SIZE) bytes" >&2; exit 1)

$(BUILD_DIR)/%.o: %.asm | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(NASM) $(ASFLAGS_KERNEL) -o $@ $<

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o $@ $<

$(KERNEL_ELF): $(OBJECTS) linker.ld
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS)

$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@

check-kernel-size: $(KERNEL_BIN)
	@actual="$$(wc -c < $(KERNEL_BIN))"; \
	if [ "$$actual" -gt "$(KERNEL_MAX_BYTES)" ]; then \
		echo "error: kernel.bin is $$actual bytes; boot sector loads only $(KERNEL_SECTORS) sectors ($(KERNEL_MAX_BYTES) bytes)" >&2; \
		exit 1; \
	fi

$(KERNEL_PADDED): $(KERNEL_BIN) check-kernel-size
	cp $(KERNEL_BIN) $@
	truncate -s $(KERNEL_MAX_BYTES) $@

$(IMAGE): $(BOOT_BIN) $(KERNEL_PADDED)
	cat $(BOOT_BIN) $(KERNEL_PADDED) > $@

run: $(IMAGE)
	$(QEMU) -drive format=raw,file=$(IMAGE) -serial stdio

debug: $(IMAGE) $(KERNEL_ELF)
	$(QEMU) -drive format=raw,file=$(IMAGE) -serial stdio -S -s

disasm: $(KERNEL_ELF)
	$(OBJDUMP) -D -Mintel $< > $(DISASM)
	@echo "wrote $(DISASM)"

symbols: $(KERNEL_ELF)
	$(NM) -n $< > $(SYMBOLS)
	@echo "wrote $(SYMBOLS)"

format:
	$(CLANG_FORMAT) -i $(FORMAT_FILES)

clean:
	rm -rf $(BUILD_DIR)
