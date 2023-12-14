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
	rm -rf $(BUILD) tmp boot.img
	
run: all
	truncate -s 16M boot.img
	mkfs.fat -F 16 boot.img
	dd if=$(BUILD)$(BOOT) of=boot.img conv=notrunc
	mkdir -p tmp
	mount boot.img tmp
	mkdir -p tmp/boot
	cp $(BUILD)$(BIN2) tmp/boot/boot.bin
	sync
	umount tmp
	hexdump boot.img -C
	qemu-system-i386 -drive file=boot.img,format=raw,index=0,media=disk

%.bin:%.asm
	mkdir -p $(BUILD)$(shell dirname $<)
	$(AS) $< -o $(BUILD)$@