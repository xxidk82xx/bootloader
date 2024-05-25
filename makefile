export include = include/

export BUILD = build/
export AS = nasm

.PHONY: all

all:
	@$(MAKE) -C stage1
	@$(MAKE) -C stage2
