## Step12 - Gatemate RISC-V Tutorial

### Description

This folder is step12 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step12 implements a number of improvements to reduce the size of the processor core. The original tutorial was created on a [Lattice IceStick](https://www.latticesemi.com/icestick) FPGA board. That board contains the iCE40HX-1k FPGA, having only 1280 logic cells and 64kbit BRAM. At this point of the RISC-V development, the tutorial author run out of space, and needed to optimize the design. The improvement details can be found on the original tutorial [here](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV#step-12-size-optimization-the-incredible-shrinking-core). There, the author reported the logic cell count decreased from 1341 down to 839 LUTs for the Lattice IceStick.


Comparing Cologne Chips 'p_r' "Utilization Report" (located in file SOC_pr.log), the "optimiziation" seemed to increase the Gatemate logic element count from 542 CPE (2.6%) in step11, vs. 1014 CPE (5.0%) in step12. A similar increase can be seen on a IceBreaker board. The nextpnr-ice40 router counts 447 LUTs (8%) in step11, vs. 834 LUTs (15%) in step12.

### Build FPGA Bitstream

```
step12$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                409
   Number of wire bits:           3033
   Number of public wires:          66
   Number of public wire bits:    1478
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                926
     CC_ADDF                       142
     CC_BRAM_20K                     3
     CC_BUFG                         1
     CC_DFF                         85
     CC_IBUF                         3
     CC_LUT1                        37
     CC_LUT2                        34
     CC_LUT3                       208
     CC_LUT4                       404
     CC_OBUF                         9
...
End of script. Logfile hash: 16353359c4, CPU: user 0.82s system 0.31s, MEM: 25.50 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 34% 1x abc (0 sec), 12% 27x opt_expr (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step12$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
Label:          4
Label:         20
Label:         28
LEDS = 111xxxxx
LEDS = 11111110
LEDS = 11111101
LEDS = 11111100
LEDS = 11111011
LEDS = 11111010
LEDS = 11111001
LEDS = 11111000
LEDS = 11110111
LEDS = 11110110
LEDS = 11110101
LEDS = 11110100
LEDS = 11110011
LEDS = 11110010
LEDS = 11110001
LEDS = 11110000
^C** VVP Stop(0) **
** Flushing output streams.
** Current simulation time is 3155217 ticks.
> finish
** Continue **

```

### Board Programming
```
step12$ make prog
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