SRC = $(shell find * -name '*.asm')
BIN = $(patsubst %.asm, %.bin, $(SRC))
BOOT = boot.bin
BIN_DIR = build/
SRC_DIR = src/
AS = nasm

.PHONY: all

all: $(BOOT) $(clean)

clean:
	rm -rf $(BIN_DIR)
	rm $(BOOT)
	
$(BOOT):$(BIN)
	echo $(BIN)
	cat $(BIN_DIR)src/FATBPB.bin $(BIN_DIR)src/loader.bin > boot.bin

%.bin:%.asm
	mkdir -p $(BIN_DIR)$(shell dirname $<)
	$(AS) $< -o $(BIN_DIR)$@