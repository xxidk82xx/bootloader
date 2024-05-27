
.PHONY: installer loader all

installer:
	@$(MAKE) -C installer

loader:
	@$(MAKE) -C loader

all:
	@$(MAKE) -C installer
	@$(MAKE) -C loader