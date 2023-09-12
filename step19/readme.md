## Step19 - Gatemate RISC-V Tutorial

### Description

This folder is step19 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step19 uses the same code as step18. It introduces the verilator tool for faster simulation. Verilator gets called with `make vtest`.

### Build FPGA Bitstream

```
step19$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                718
   Number of wire bits:           7150
   Number of public wires:         190
   Number of public wire bits:    4977
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:               1237
     CC_ADDF                       170
     CC_BRAM_20K                     5
     CC_BUFG                         1
     CC_DFF                        106
     CC_IBUF                         3
     CC_LUT1                        37
     CC_LUT2                        78
     CC_LUT3                       345
     CC_LUT4                       482
     CC_OBUF                         9
     CC_PLL                          1
...
End of script. Logfile hash: 36bb04ea8a, CPU: user 1.47s system 0.62s, MEM: 31.69 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 26% 1x abc (0 sec), 14% 28x opt_expr (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step19$ make vtest
Running verilator testbench simulation
test ! -d ./obj_dir || rm -rf ./obj_dir
test -e SOC.cpp || echo 'Error SOC.cpp not found!'
#/usr/bin/verilator --CFLAGS '-I..' -DBENCH -Wno-fatal --top-module SOC --cc --exe SOC.cpp SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v ../rtl-shared/emmitter_uart.v
/usr/bin/verilator -DBENCH -Wno-fatal --top-module SOC --cc --exe SOC.cpp SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v ../rtl-shared/emmitter_uart.v SOC_tb.v
(cd obj_dir; make -f VSOC.mk)
make[1]: Entering directory '/mnt/hgfs/fpga/projects/git/gatemate-riscv/step19/obj_dir'
g++  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable -Wno-shadow       -Os -c -o SOC.o ../SOC.cpp
g++  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable -Wno-shadow       -Os -c -o verilated.o /usr/share/verilator/include/verilated.cpp
g++  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable -Wno-shadow       -Os -c -o verilated_threads.o /usr/share/verilator/include/verilated_threads.cpp
/usr/bin/python3 /usr/share/verilator/bin/verilator_includer -DVL_INCLUDE_OPT=include VSOC.cpp VSOC___024root__DepSet_h71e4205e__0.cpp VSOC___024root__DepSet_hfcbc957c__0.cpp VSOC__ConstPool_0.cpp VSOC___024root__Slow.cpp VSOC___024root__DepSet_h71e4205e__0__Slow.cpp VSOC___024root__DepSet_hfcbc957c__0__Slow.cpp VSOC__Syms.cpp > VSOC__ALL.cpp
g++  -I.  -MMD -I/usr/share/verilator/include -I/usr/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fcf-protection=none -Wno-bool-operation -Wno-sign-compare -Wno-uninitialized -Wno-unused-but-set-variable -Wno-unused-parameter -Wno-unused-variable -Wno-shadow       -Os -c -o VSOC__ALL.o VSOC__ALL.cpp
echo "" > VSOC__ALL.verilator_deplist.tmp
Archive ar -rcs VSOC__ALL.a VSOC__ALL.o
g++    SOC.o verilated.o verilated_threads.o VSOC__ALL.a    -pthread -lpthread -latomic   -o VSOC
rm VSOC__ALL.verilator_deplist.tmp
make[1]: Leaving directory '/mnt/hgfs/fpga/projects/git/gatemate-riscv/step19/obj_dir'
test -e obj_dir/VSOC && obj_dir/VSOC || echo 'Make failed, no obj_dir/VSOC found!'
Label:         12
Label:         16
Label:         76
Label:         84
Label:         96
Label:        188
Label:        264
Label:        272
Label:        284
Label:        292
Label:        308
Label:        316
Label:        328
Label:        344
LEDS: 11111
^Cmake: *** [../config.mk:53: vtest] Interrupt
```

### Board Programming
```
step19$ make prog
Programming E1 SPI Config:
/home/fm/cc-toolchain-linux/bin/openFPGALoader/openFPGALoader -b gatemate_evb_spi SOC_00.cfg
Jtag frequency : requested 6.00MHz   -> real 6.00MHz
Detail:
Jedec ID          : c2
memory type       : 28
memory capacity   : 17
EDID + CFD length : c2
EDID              : 1728
CFD               :
00
Detail:
Jedec ID          : c2
memory type       : 28
memory capacity   : 17
EDID + CFD length : c2
EDID              : 1728
CFD               :
flash chip unknown: use basic protection detection
Erasing: [==================================================] 100.00%
Done
Writing: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```
### Output
With the UART assigned to the E1 boards PMODB connector pins, the Digilent PMOD-UART converter to see the RISC-V program output, and we can display it in a terminal window. The terminal output runs at a bitdrate of 833.333, falling short of the UART target speed of 1Mbaud (1.000.000). The root cause is discussed in [Issue #3](https://github.com/fm4dd/gatemate-riscv/issues/3).