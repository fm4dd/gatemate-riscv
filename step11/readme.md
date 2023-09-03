## Step11 - Gatemate RISC-V Tutorial

### Description

This folder is step11 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step11 separates the SOC components into separate modules for processor and memory.

The Memory module interface gets the clk signal, mem_addr, and mem_rstrb inputs. Whenever the processor wants to read from memory, it sends the address to be read into mem_addr, then raises mem_rstrb to 1. This instructs the Memory module to return the data for mem_addr to be put into the mem_rdata output.

The Processor module has the mem_addr and mem_rstrb signal (as outputs), the mem_rdata signal (as input). We also externalize the x1 register (as output) that can be used for visual debugging, and plug it to the LEDs.



![](../images/step11-modules.svg)

For now we keep the SOC, Memory and Processor modules inside the same single file SOC.v. To test the CPU, the same assembly program from step09 is store into Memory, which implements a 5-bit counter. The board LED's show the counter.

### Build FPGA Bitstream

```
step11$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                210
   Number of wire bits:           1858
   Number of public wires:          58
   Number of public wire bits:    1012
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                469
     CC_ADDF                       101
     CC_BRAM_20K                     3
     CC_BUFG                         2
     CC_DFF                         58
     CC_IBUF                         3
     CC_LUT1                        37
     CC_LUT2                        25
     CC_LUT3                       148
     CC_LUT4                        51
     CC_MX4                         32
     CC_OBUF                         9
...
End of script. Logfile hash: be7aec9440, CPU: user 0.75s system 0.05s, MEM: 25.28 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 23% 1x abc (0 sec), 14% 27x opt_expr (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step11$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
Label:          8
LEDS = 111xxxxx
ALUreg rd= 1 rs1= 0 rs2= 0 funct3=000
x1 <= 00000000000000000000000000000000
ALUimm rd= 2 rs1= 0 imm=31 funct3=000
x2 <= 00000000000000000000000000011111
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000001
LEDS = 11111110
BRANCH rs1=1 rs2=2
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000010
LEDS = 11111101
BRANCH rs1=1 rs2=2
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000011
LEDS = 11111100
BRANCH rs1=1 rs2=2
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000100
LEDS = 11111011
BRANCH rs1=1 rs2=2
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000101
LEDS = 11111010
BRANCH rs1=1 rs2=2
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000110
LEDS = 11111001
BRANCH rs1=1 rs2=2
^C** VVP Stop(0) **
** Flushing output streams.
** Current simulation time is 22936610 ticks.
> finish
** Continue **
```

### Board Programming
```
step11$ make prog
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