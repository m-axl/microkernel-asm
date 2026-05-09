NASM := nasm
QEMU := qemu-system-x86_64

BUILD_DIR := build
BOOT_SRC := boot/boot.asm
KERNEL_SRC := kernel/kernel.asm
BOOT_BIN := $(BUILD_DIR)/boot.bin
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
OS_IMG := $(BUILD_DIR)/os.img
KERNEL_SECTORS := 8
KERNEL_MAX_SIZE := $(shell expr $(KERNEL_SECTORS) \* 512)

.PHONY: all clean run debug check quality

all: $(OS_IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT_BIN): $(BOOT_SRC) | $(BUILD_DIR)
	$(NASM) -f bin $< -o $@

$(KERNEL_BIN): $(KERNEL_SRC) include/kernel.inc kernel/memory.asm kernel/scheduler.asm kernel/ipc.asm servers/fs_server.asm servers/driver_server.asm | $(BUILD_DIR)
	$(NASM) -I . -f bin $< -o $@
	@test "$$(stat -c%s $@)" -le "$(KERNEL_MAX_SIZE)" || \
		(echo "kernel image is larger than $(KERNEL_MAX_SIZE) bytes"; exit 1)
	truncate -s $(KERNEL_MAX_SIZE) $@

$(OS_IMG): $(BOOT_BIN) $(KERNEL_BIN)
	cat $(BOOT_BIN) $(KERNEL_BIN) > $@

check: all
	@test "$$(stat -c%s $(BOOT_BIN))" -eq 512
	@test "$$(stat -c%s $(KERNEL_BIN))" -eq "$(KERNEL_MAX_SIZE)"
	@test "$$(stat -c%s $(OS_IMG))" -eq "$$(expr 512 + $(KERNEL_MAX_SIZE))"
	@printf "Boot signature: "
	@od -An -tx1 -j510 -N2 $(BOOT_BIN)
	@od -An -tx1 -j510 -N2 $(BOOT_BIN) | grep -qi "55 aa"
	@$(NASM) -I . -f bin $(BOOT_SRC) -o /tmp/microkernel-boot-check.bin
	@$(NASM) -I . -f bin $(KERNEL_SRC) -o /tmp/microkernel-kernel-check.bin

quality: check
	sh scripts/quality.sh

run: all
	$(QEMU) -drive format=raw,file=$(OS_IMG)

debug: all
	$(QEMU) -drive format=raw,file=$(OS_IMG) -serial stdio -s -S

clean:
	rm -rf $(BUILD_DIR)
