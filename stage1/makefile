SRC = $(wildcard *.asm)
BOOT = $(patsubst %.asm, %.bin, $(SRC))

all: $(BOOT)

%.bin:%.asm
	mkdir -p $(BUILD)$(shell dirname $<)
	$(AS) $< -o $(BUILD)$@