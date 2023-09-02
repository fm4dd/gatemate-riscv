## Step08 - Gatemate RISC-V Tutorial

### Description

This folder is step08 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step08 implements two jump instructions JAL (jump and link) and JALR (jump and link register).

The simple assembly test code below verifies the implementation works.
```verilog
`include "../rtl-shared/riscv_assembly.v"

      integer L0_=4;
      initial begin
         ADD(x1,x0,x0);
      Label(L0_);
         ADDI(x1,x1,1);
         JAL(x0,LabelRef(L0_));
         EBREAK();
         endASM();
      end
```

The CPU executes a small assembly code that implements a 5-bit counter. The board LED's show the counter.

### Build FPGA Bitstream

Note: Because of an [issue](https://github.com/fm4dd/gatemate-riscv/issues/1) with Cologne Chip 'p_r' executable, this step08 uses a local constraints file instead of the global one.
```
step08$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                467
   Number of wire bits:           2917
   Number of public wires:          38
   Number of public wire bits:     684
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                956
     CC_ADDF                       210
     CC_BRAM_20K                     3
     CC_BUFG                         2
     CC_DFF                         61
     CC_IBUF                         3
     CC_LUT1                        37
     CC_LUT2                        36
     CC_LUT3                       271
     CC_LUT4                       294
     CC_MX4                         30
     CC_OBUF                         9
...
End of script. Logfile hash: 726018c003, CPU: user 1.04s system 0.17s, MEM: 29.50 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 26% 1x abc (0 sec), 16% 30x opt_expr (0 sec), ...
test -e gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step08$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
Label:          4
LEDS = 111xxxxx
ALUreg rd= 1 rs1= 0 rs2= 0 funct3=000
x1 <= 00000000000000000000000000000000
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000001
LEDS = 11111110
JAL
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000010
LEDS = 11111101
JAL
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000011
LEDS = 11111100
JAL
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000100
LEDS = 11111011
JAL
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000101
LEDS = 11111010
JAL
^C** VVP Stop(0) **
** Flushing output streams.
** Current simulation time is 48244798 ticks.
> finish
** Continue **
```

### Board Programming
```
step08$ make prog
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