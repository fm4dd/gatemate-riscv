### ------------------------------------------------------------ ###
### Central Makefile with shared settings across step01...19 The ###
### Steps only differ by using additional code modules that are  ###
### added into each step folders Makefile.                       ###
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
# ADD_SRC =

## central, single HW constraints file, requires ../ because its called from subdir
PIN_DEF = ../gatemate-e1.ccf

all: impl

synth_vlog: $(PROJ).v
	$(YOSYS) -p 'read -sv $(PROJ).v $(ADD_SRC); synth_gatemate -top $(PROJ) -vlog $(PROJ)_synth.v'

impl: synth_vlog
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
	#/usr/bin/verilator --CFLAGS '-I..' -DBENCH -Wno-fatal --top-module $(PROJ) --cc --exe $(PROJ).cpp $(PROJ).v $(ADD_SRC)
	/usr/bin/verilator -DBENCH -Wno-fatal --top-module $(PROJ) --cc --exe $(PROJ).cpp $(PROJ).v $(ADD_SRC) $(PROJ)_tb.v
	(cd obj_dir; make -f VSOC.mk)
	test -e obj_dir/V$(PROJ) && obj_dir/V$(PROJ) || echo 'Make failed, no obj_dir/V$(PROJ) found!'

prog: $(PROJ)_00.cfg
	@echo 'Programming E1 SPI Config:'
	$(OFL) -b gatemate_evb_spi $<

flash: $(PROJ)_00.cfg
	@echo 'Programming E1 SPI Flash:'
	$(OFL) -b gatemate_evb_spi -f --verify $<

clean:
	rm -f $(PROJ)_synth.v $(PROJ)_pr.log $(PROJ)_00.* *.id *.idh *.tb *.prn *.ref* lut*.txt *.idh *.net *.pos *.cdf *.pathes abc.history
	rm -rf obj_dir

.SECONDARY:
.PHONY: all prog clean
