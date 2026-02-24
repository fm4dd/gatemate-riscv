### Local Makefile, adding the exercise-specific code modules.  ###
### Anything else is defined in the upper directory centralized ###
### Makefile config.mk                                          ###
###            --- Local Firmware Integration ---               ###
### Append firmware.bin as a dependency to existing targets.    ###
### ----------------------------------------------------------- ###
include ../config.mk

# 1. Add firmware.hex as a dependency for synthesis and simulation
synth_vlog: firmware.bin
impl: firmware.bin
test: firmware.bin
vtest: firmware.bin

# 2. Rule to build the hex file by calling the sub-directory Makefile
firmware.bin: src-hello/hello.S src-hello/putchar.S src-hello/start.S src-hello/wait.S
	@echo "--- Building RISC-V Firmware ---"
	$(MAKE) -C src-hello
	cp src-hello/firmware.bin .

# 3. Add source files for the FPGA synthesis
ADD_SRC += ../rtl-shared/clockworks.v \
           ../rtl-shared/pll_gatemate.v \
           ../rtl-shared/emmitter_uart.v \
           ../rtl-shared/spi_flash.v

# 4. Overwriting the 'prog' target to upload the RISC-V program first
#    to Flash at 1MB offset specified with -o 0x1000000 or -o 1048576
prog: $(PROJ).bit
	@echo 'Loading RISC-V program to Flash at 1M offset (1048576 bytes):'
	$(OFL) -b gatemate_evb_spi -o 1048576 -f firmware.bin
	@echo 'Programming E1 SPI Config:'
	$(OFL) -b gatemate_evb_spi -f $<

# Overwriting 'flash' (usually an alias for prog, but defined explicitly here)
flash: prog

# 5. Clean the firmware when cleaning the project
clean: clean_firmware

clean_firmware:
	$(MAKE) -C src-hello clean
	rm -f firmware.bin
