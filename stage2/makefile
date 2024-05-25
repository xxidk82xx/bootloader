SRC = $(wildcard *.asm)
BOOT = $(patsubst %.asm, %.bin, $(SRC))

.PHONY: all

all: $(BOOT)

%.bin:%.asm
	mkdir -p $(BUILD)$(shell dirname $<)
	$(AS) $< -o $(BUILD)$@