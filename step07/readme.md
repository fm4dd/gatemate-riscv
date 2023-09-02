## Step07 - Gatemate RISC-V Tutorial

### Description

This folder is step07 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step07 implements the same small CPU test program as we had in the previous step06, but this time its written as a Verilog assembly program into the top Verlog module, which is much easier to read.
```verilog
`include "../rtl-shared/riscv_assembly.v"

   initial begin
      PC = 0;
      ADD(x0,x0,x0);
      ADD(x1,x0,x0);
      ADDI(x1,x1,1);
      ADDI(x1,x1,1);
      ADDI(x1,x1,1);
      ADDI(x1,x1,1);
      ADD(x2,x1,x0);
      ADD(x3,x1,x2);
      SRLI(x3,x3,3);
      SLLI(x3,x3,31);
      SRAI(x3,x3,5);
      SRLI(x1,x3,26);
      EBREAK();
   end
```

The CPU executes a small test program. The board LED's show the result of the ALU on the LEDs.

### Build FPGA Bitstream
```
step07$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                323
   Number of wire bits:           1908
   Number of public wires:          34
   Number of public wire bits:     556
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                675
     CC_ADDF                        94
     CC_BRAM_20K                     3
     CC_BUFG                         2
     CC_DFF                         37
     CC_IBUF                         3
     CC_LUT1                        37
     CC_LUT2                        54
     CC_LUT3                       256
     CC_LUT4                       150
     CC_MX4                         30
     CC_OBUF                         9
...
End of script. Logfile hash: cd79047eea, CPU: user 0.18s system 0.70s, MEM: 27.95 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 27% 1x abc (0 sec), 14% 30x opt_expr (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step07$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
LEDS = 111xxxxx
ALUreg rd= 0 rs1= 0 rs2= 0 funct3=000
ALUreg rd= 1 rs1= 0 rs2= 0 funct3=000
x1 <= 00000000000000000000000000000000
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000001
LEDS = 11111110
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000010
LEDS = 11111101
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000011
LEDS = 11111100
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000100
LEDS = 11111011
ALUreg rd= 2 rs1= 1 rs2= 0 funct3=000
x2 <= 00000000000000000000000000000100
ALUreg rd= 3 rs1= 1 rs2= 2 funct3=000
x3 <= 00000000000000000000000000001000
ALUimm rd= 3 rs1= 3 imm=3 funct3=101
x3 <= 00000000000000000000000000000001
ALUimm rd= 3 rs1= 3 imm=31 funct3=001
x3 <= 10000000000000000000000000000000
ALUimm rd= 3 rs1= 3 imm=1029 funct3=101
x3 <= 11111100000000000000000000000000
ALUimm rd= 1 rs1= 3 imm=26 funct3=101
x1 <= 00000000000000000000000000111111
LEDS = 11100000
SYSTEM
```

### Board Programming
```
step07$ make prog
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