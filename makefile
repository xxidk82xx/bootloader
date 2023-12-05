SRC1 = $(shell find stage1/* -name '*.asm')
SRC2 = $(shell find stage2/* -name '*.asm')
BIN1 = stage1/boot.bin
BIN2 = stage2/stage2.bin
BUILD = build/
BOOT = boot.bin
AS = nasm

.PHONY: all

all: $(BIN1) $(BIN2) 
	cat $(addprefix build/, $(BIN1)) > $(BUILD)$(BOOT)
	

clean:
	rm -rf $(BUILD)
	
run: all
	dd if=$(BUILD)$(BOOT) of=/dev/sda
	mkdir -p tmp/boot
	cp $(BUILD)$(BIN2) tmp/boot/boot.bin
	qemu-system-i386 -drive file=/dev/sda,format=raw,index=0,media=disk

%.bin:%.asm
	mkdir -p $(BUILD)$(shell dirname $<)
	$(AS) $< -o $(BUILD)$@