SRC = $(shell find * -name '*.asm')
BIN = src/boot.bin src/table.bin
BOOT = boot.bin
AS = nasm

.PHONY: all

all: $(BIN) 
	cat $(addprefix build/, $(BIN)) > build/$(BOOT)
	truncate -s 16M build/$(BOOT)

clean:
	rm -rf build/
	
run: all
	qemu-system-i386 -drive file=build/$(BOOT),format=raw,index=0,media=disk

%.bin:%.asm
	mkdir -p build/$(shell dirname $<)
	$(AS) $< -o build/$@