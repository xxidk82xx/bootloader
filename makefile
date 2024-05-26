working_dir := $(shell pwd)/
export include := include/

export BUILD = $(working_dir)build/
export AS = nasm
export ASFLAGS = -i $(working_dir)

image = boot.img
stage1 = $(BUILD)stage1/stage1.bin
stage2 = $(BUILD)stage2/stage2.bin

.PHONY: all run

all:
	@$(MAKE) -C stage1
	@$(MAKE) -C stage2

%.bin:
	$(MAKE) -C $(basename $(notdir $@))

$(image): $(stage1) $(stage2)
	truncate -s 16M boot.img
	mkfs.fat -F 16 boot.img
	dd if=$(stage1) of=boot.img conv=notrunc
	mkdir -p tmp
	mount boot.img tmp
	mkdir -p tmp/boot
	cp $(stage2) tmp/boot/boot.bin
	sync

run: $(image)
	sync
	hexdump boot.img -C
	qemu-system-i386 -drive file=boot.img,format=raw,index=0,media=disk

clean:
	rm -rf $(BUILD)
