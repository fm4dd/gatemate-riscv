### Local Makefile, adding the exercise-specific code modules.  ###
### Anything else is defined in the upper directory centralized ###
### Makefile config.mk                                          ###
###            --- Local Firmware Integration ---               ###
### Append firmware.hex as a dependency to existing targets.    ###
### ----------------------------------------------------------- ###
include ../config.mk

# 1. Add firmware.hex as a dependency for synthesis and simulation
synth_vlog: firmware.hex
impl: firmware.hex
test: firmware.hex
vtest: firmware.hex

# 2. Rule to build the hex file by calling the sub-directory Makefile
firmware.hex: src/print.c src/putchar.S src/start.S src/ST_NICCC.c
	@echo "--- Building RISC-V Firmware ---"
	$(MAKE) -C src
	cp src/firmware.hex .

# 3. Add source files for the FPGA synthesis
ADD_SRC += ../rtl-shared/clockworks.v \
           ../rtl-shared/pll_gatemate.v \
           ../rtl-shared/emmitter_uart.v \
           ../rtl-shared/spi_flash.v

# 4. Overwriting the 'prog' target
prog: $(PROJ).bit
	@echo 'Programming scene data at 1M offset (1048576 bytes):'
	$(OFL) -b gatemate_evb_spi -o 1048576 data/scene1.dat -f
	@echo 'Programming E1 SPI Config:'
	$(OFL) -b gatemate_evb_spi -f $<

# Overwriting 'flash' (usually an alias for prog, but defined explicitly here)
flash: prog

# 5. Clean the firmware when cleaning the project
clean: clean_firmware

clean_firmware:
	$(MAKE) -C src clean
	rm -f firmware.hex
