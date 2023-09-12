## Step18 - Gatemate RISC-V Tutorial

### Description

This folder is step18 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step18 implements a RISC-V assembly program that computes a crude, ASCII-art version of the Mandelbrot set that is send to the UART and displayed in a terminal window. Module design is the same as step17:
<img src="../images/step17-18-modules.svg">

### Build FPGA Bitstream

```
step18$ make
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
End of script. Logfile hash: 6f83220d37, CPU: user 1.07s system 1.12s, MEM: 31.74 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 27% 1x abc (0 sec), 14% 28x opt_expr (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step18$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v ../rtl-shared/emmitter_uart.v
/usr/bin/vvp SOC.tb
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
LEDS = 111xxxxx
LEDS = 11110101
LEDS = 11111010
LEDS = 11110101
LEDS = 11111010
LEDS = 11110101
LEDS = 11111010
LEDS = 11110101
LEDS = 11111010
LEDS = 11110101
LEDS = 11111111
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@##################@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@#########################@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
@@@@@@@@@@@@@@@@@@@@@@@@@###############################@@@@@@@@@@@@@@@@@@@@@@@@ 
@@@@@@@@@@@@@@@@@@@@@@@###################################@@@@@@@@@@@@@@@@@@@@@@ 
@@@@@@@@@@@@@@@@@@@@@#######################################@@@@@@@@@@@@@@@@@@@@ 
@@@@@@@@@@@@@@@@@@@@##########################################@@@@@@@@@@@@@@@@@@ 
@@@@@@@@@@@@@@@@@@#############################################@@@@@@@@@@@@@@@@@ 
@@@@@@@@@@@@@@@@@################################################@@@@@@@@@@@@@@@ 
@@@@@@@@@@@@@@@###################################################@@@@@@@@@@@@@@ 
@@@@@@@@@@@@@@#####################################################@@@@@@@@@@@@@ 
@@@@@@@@@@@@@#######################################################@@@@@@@@@@@@ 
@@@@@@@@@@@@#########################################################@@@@@@@@@@@ 
@@@@@@@@@@@###########################################################@@@@@@@@@@ 
@@@@@@@@@@###############%%%%%%%%%%%###################################@@@@@@@@@ 
@@@@@@@@@############%%%%%%%%%%%%%%%%%%%################################@@@@@@@@ 
@@@@@@@@@#########%%%%%%%%%%%%%%%%%%%%%%%%%##############################@@@@@@@ 
@@@@@@@@########%%%%%%%%%%%%%%%%%xxxxxxxx%%%%%###########################@@@@@@@ 
@@@@@@@#######%%%%%%%%%%%%%%%%%xxxxo  ooxxx%%%%###########################@@@@@@ 
@@@@@@@#####%%%%%%%%%%%%%%%%%xxxxxo;: ;;oxxxx%%%%##########################@@@@@ 
@@@@@@#####%%%%%%%%%%%%%%%%xxxxxxoo;: .  oxxxx%%%%#########################@@@@@ 
@@^C** VVP Stop(0) **
** Flushing output streams.
** Current simulation time is 27146677 ticks.
> finish
** Continue **
```

### Board Programming
```
step18$ make prog
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
With the UART assigned to the E1 boards PMODB connector pins, the Digilent PMOD-UART converter to see the RISC-V program output, and we can display it in a terminal window:

<img src="../images/step18-desktop.png">

The terminal output runs at a bitdrate of 833.333, falling short of the UART target speed of 1Mbaud (1.000.000). The root cause is discussed in [Issue #3](https://github.com/fm4dd/gatemate-riscv/issues/3).