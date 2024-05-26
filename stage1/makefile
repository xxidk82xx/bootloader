SRC = $(wildcard *.asm)
BOOT = $(patsubst %.asm, %.bin, $(SRC))
BUILD :=$(BUILD)stage1/

all: $(BOOT)

%.bin:%.asm
	mkdir -p $(BUILD)$(shell dirname $<)
	$(AS) $< $(ASFLAGS) -o $(BUILD)$@