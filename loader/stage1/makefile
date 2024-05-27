SRC = $(wildcard *.asm)
BOOT = $(patsubst %.asm, %.bin, $(SRC))
BUILD :=$(BUILD)stage1/

.PHONY: all

all: $(BOOT)

%.bin:%.asm
	mkdir -p $(BUILD)$(shell dirname $<)
	$(AS) $< $(ASFLAGS) -o $(BUILD)$@