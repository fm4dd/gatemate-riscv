### ------------------------------------------------------------ ###
### Local project Makefile for step22.                           ###
### ------------------------------------------------------------ ###

## toolchain
# disable CC-provided Yosys, switch to "OSS CAD Suite" version
# see https://github.com/fm4dd/gatemate-riscv/issues/8
YOSYS = /home/fm/oss-cad-suite/bin/yosys
# disable CC-provided openFPGALoader, switch to "OSS CAD Suite" version
# see https://github.com/fm4dd/gatemate-riscv/issues/5
OFL   = /home/fm/oss-cad-suite/bin/openFPGALoader
PR    = /home/fm/cc-toolchain-linux/bin/p_r/p_r

GTKW = gtkwave
IVL  = iverilog
VVP  = vvp
IVLFLAGS = -Winfloop -g2012 -gspecify -Ttyp

## simulation libraries
CELLS_SYNTH = /home/fm/cc-toolchain-linux/bin/yosys/share/gatemate/cells_sim.v
CELLS_IMPL = /home/fm/cc-toolchain-linux/bin/p_r/cpelib.v

## top module, same for each step
PROJ = SOC

ADD_SRC += ../rtl-shared/clockworks.v \
           ../rtl-shared/pll_gatemate.v \
           ../rtl-shared/emmitter_uart.v \
           ../rtl-shared/spi_flash.v

## central, single HW constraints file, requires ../ because its called from subdir
PIN_DEF = ../gatemate-e1.ccf

## firmware.hex contains the RISC-V app code, created from one of the src-xxx folders
ST_NICCC: $(PROJ).v
	$(MAKE) -C src
	cp src/firmware.hex .
	$(YOSYS) -p 'read -sv $(PROJ).v $(ADD_SRC); synth_gatemate -top $(PROJ) -vlog $(PROJ)_synth.v'
	test -e $(PIN_DEF) || exit
	$(PR) -i $(PROJ)_synth.v -o $(PROJ) -ccf $(PIN_DEF) +uCIO > $(PROJ)_pr.log

## iVerilog simulation
test:
	@echo 'Running testbench simulation'
	test ! -e $(PROJ).tb || rm $(PROJ).tb
	test ! -e $(PROJ).vcd || rm $(PROJ).vcd
	/usr/bin/iverilog -DBENCH -o $(PROJ).tb -s $(PROJ)_tb $(PROJ)_tb.v $(PROJ).v $(ADD_SRC)
	/usr/bin/vvp $(PROJ).tb

## Verilator simulation
vtest:
	@echo 'Running verilator testbench simulation'
	test ! -d ./obj_dir || rm -rf ./obj_dir
	test -e $(PROJ).cpp || echo 'Error $(PROJ).cpp not found!'
	/usr/bin/verilator -DBENCH -Wno-fatal --top-module $(PROJ) --cc --exe $(PROJ).cpp $(PROJ).v $(ADD_SRC) $(PROJ)_tb.v
	(cd obj_dir; make -f VSOC.mk)
	test -e obj_dir/V$(PROJ) && obj_dir/V$(PROJ) || echo 'Make failed, no obj_dir/V$(PROJ) found!'

prog: $(PROJ)_00.cfg.bit
	@echo 'Programming scene data at 1M offset:'
	$(OFL) -b gatemate_evb_spi -o 1048576 data/scene1.dat -f
	@echo 'Programming E1 SPI Config:'
	$(OFL) -b gatemate_evb_spi -f $<

clean:
	rm -f $(PROJ)_synth.v $(PROJ)_pr.log $(PROJ)_00.* *.id *.tb *.prn *.ref* lut*.txt *.idh *.net *.pos *.cdf *.pathes firmware.hex
	rm -rf obj_dir
	$(MAKE) -C src clean

.SECONDARY:
.PHONY: all prog clean
