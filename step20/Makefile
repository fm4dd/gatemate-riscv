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
firmware.hex: src-hello/hello.S src-hello/putchar.S src-hello/start.S
	@echo "--- Building RISC-V Firmware ---"
	$(MAKE) -C src-hello
	cp src-hello/firmware.hex .

# 3. Add source files for the FPGA synthesis
ADD_SRC += ../rtl-shared/clockworks.v \
           ../rtl-shared/pll_gatemate.v \
           ../rtl-shared/emmitter_uart.v

# 4. Clean the firmware when cleaning the project
clean: clean_firmware

clean_firmware:
	$(MAKE) -C src-hello clean
	rm -f firmware.hex
