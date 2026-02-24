### config.mk
### ------------------------------------------------------------ ###
### Gatemate Makefile for oss-cad-suite toolchain (2026-02-11)   ###
###                                                              ###
### Central Makefile with shared settings across step01...19 The ###
### Steps only differ by using additional code modules that are  ###
### added into each step folders Makefile.                       ###
### ------------------------------------------------------------ ###

## toolchain location
YOSYS = /home/fm/oss-cad-suite/bin/yosys
PR    = /home/fm/oss-cad-suite/bin/nextpnr-himbaechel
PACK  = /home/fm/oss-cad-suite/bin/gmpack
OFL   = /home/fm/oss-cad-suite/bin/openFPGALoader
VLTR  = /home/fm/oss-cad-suite/bin/verilator
GTKW  = /home/fm/oss-cad-suite/bin/gtkwave
IVL   = /home/fm/oss-cad-suite/bin/iverilog
VVP   = /home/fm/oss-cad-suite/bin/vvp
IVLFLAGS = -Winfloop -g2012 -gspecify -Ttyp -DSIMULATION

## simulation libraries (oss-cad-suite: cpelib.v is now cells_sim.v)
CELLS_SYNTH = /home/fm/oss-cad-suite/share/yosys/gatemate/cells_sim.v

## top module, same for each step
PROJ = SOC
# ADD_SRC =

## central, single HW constraints file, requires ../ because its called from subdir
PIN_DEF = ../gatemate-e1.ccf

all: impl

## --------------------------------------------------------------------------
## In synthesis we create both output formats: Verilog and JSON.
## The old Verilog output is needed because iVerlog does not understand JSON.
## --------------------------------------------------------------------------
synth_vlog: $(PROJ).v
	@test -d log || mkdir log
	@test -d net || mkdir net
	$(YOSYS) -ql log/synth.log -p 'read -sv $(PROJ).v $(ADD_SRC); synth_gatemate -top $(PROJ) -luttree -nomx8 -vlog net/$(PROJ)_synth.v; write_json net/$(PROJ)_synth.json'

## --------------------------------------------------------------------------
## In place_&_route we tell nextpnr to export a Verilog netlist of the design
## with '--write net/$(PROJ)_impl.v'. This is needed for iVerilog simulations.
## --------------------------------------------------------------------------
impl: synth_vlog
	test -e $(PIN_DEF) || exit
	$(PR) --device=CCGM1A1 --json net/$(PROJ)_synth.json --write net/$(PROJ)_impl.v -o out=net/$(PROJ)_impl.txt -o ccf=$(PIN_DEF) --router router2 > log/$@.log
	$(PACK) --input net/$(PROJ)_impl.txt --bit $(PROJ).bit

## --------------------------------------------------------------------------
## iVerilog simulation
## --------------------------------------------------------------------------
test:
	@echo 'Running testbench simulation'
	test ! -e $(PROJ).tb || rm $(PROJ).tb
	test ! -e $(PROJ).vcd || rm $(PROJ).vcd
	$(IVL) -DBENCH -o $(PROJ).tb -s $(PROJ)_tb $(PROJ)_tb.v $(PROJ).v $(ADD_SRC)
	$(VVP) $(PROJ).tb

## --------------------------------------------------------------------------
## Verilator simulation
## --------------------------------------------------------------------------
vtest:
ifeq ($(wildcard $(PROJ).cpp),)
	@echo "Error $(PROJ).cpp not found!"
else
	@echo 'Running verilator testbench simulation'
	test ! -d ./obj_dir || rm -rf ./obj_dir
	$(VLTR) -DBENCH -Wno-fatal --top-module $(PROJ) --cc --exe $(PROJ).cpp $(PROJ).v $(ADD_SRC) $(PROJ)_tb.v
	(cd obj_dir; $(MAKE) -f V$(PROJ).mk)
	test -e obj_dir/V$(PROJ) && obj_dir/V$(PROJ) || echo 'Make failed, no obj_dir/V$(PROJ) found!'
endif

prog: $(PROJ).bit
	@echo 'Programming E1 SPI Config:'
	$(OFL) $(OFLFLAGS) -b gatemate_evb_spi $<

flash: $(PROJ).bit
	@echo 'Programming E1 SPI Flash:'
	$(OFL) $(OFLFLAGS) -b gatemate_evb_spi -f --verify $<


## -------------------------------------------------------------
## GTKWave Waveform Generation
## -------------------------------------------------------------

# Rule to generate VCD from the RTL simulation binary
$(PROJ).vcd: $(PROJ)_sim.vvp
	@echo "Generating fresh VCD data for $(PROJ)..."
	$(VVP) -N $< -lx2

# Primary wave target: check dependencies and launch GTKWave
wave: $(PROJ).vcd
	$(GTKW) $< config.gtkw

## -------------------------------------------------------------
## make clean deletes all compiled files and the bitstream
## -------------------------------------------------------------
clean:
	$(RM) log/*.log
	$(RM) net/*_synth.json
	$(RM) net/*_synth.v
	$(RM) net/*_impl.v
	$(RM) net/*_impl.txt
	$(RM) *.tb
	$(RM) *.vcd
	$(RM) *.vvp
	$(RM) *.bit
	test ! -d log || rmdir log
	test ! -d net || rmdir net
	test ! -d obj_dir || rm -rf obj_dir

.SECONDARY:
.PHONY: all prog clean
