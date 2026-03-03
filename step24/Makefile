### Local Makefile, adding the exercise-specific code modules.  ###
### Anything else is defined in the upper directory centralized ###
### Makefile config.mk                                          ###
###            --- Local Firmware Integration ---               ###
### Append firmware.bin as a dependency to existing targets.    ###
### ----------------------------------------------------------- ###
include ../config.mk

# 1. Suppress the 'Entering directory' and 'Overriding recipe' noise
MAKEFLAGS += --no-print-directory --warn-undefined-variables

# --- 2. Configuration ---
FIRMWARE_TYPE ?= mandel

# --- 3. Top-Level Entry Points ---
# This is what happens when you just type 'make'
all: $(FIRMWARE_TYPE)

# These targets build the firmware THEN run synthesis
mandel:
	$(MAKE) build_firmware FW_DIR=src-mandel
	$(MAKE) synth_vlog
	$(MAKE) impl

pi:
	$(MAKE) build_firmware FW_DIR=src-pi
	$(MAKE) synth_vlog
	$(MAKE) impl

# --- 4. Internal Firmware Helper ---
build_firmware:
	@echo "--- Building $(FW_DIR) Firmware ---"
	$(MAKE) -C $(FW_DIR)
	cp $(FW_DIR)/firmware.bin ./firmware.bin

# --- 5. FPGA Targets ---
# Ensure synthesis knows it needs the firmware file
synth_vlog: firmware.bin
impl: firmware.bin

# --- 6. Add source files for synthesis ---
ADD_SRC += ../rtl-shared/clockworks.v \
           ../rtl-shared/pll_gatemate.v \
           ../rtl-shared/emmitter_uart.v \
           ../rtl-shared/spi_flash.v

# --- 7. Overrides ---
# We use standard ':' here. To avoid the warning block, 
# we'll just let the local definition override the config.mk one.
prog: firmware.bin $(PROJ).bit
	@echo 'Loading RISC-V program to Flash at 1M offset:'
	$(OFL) -b gatemate_evb_spi -o 1048576 -f firmware.bin
	@echo 'Programming FPGA Bitstream:'
	$(OFL) -b gatemate_evb_spi -f $(PROJ).bit

clean: clean_firmware

clean_firmware:
	$(MAKE) -C src-mandel clean
	$(MAKE) -C src-pi clean
	rm -f firmware.bin

.PHONY: all mandel pi build_firmware clean_firmware prog
