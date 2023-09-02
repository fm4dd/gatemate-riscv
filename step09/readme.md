## Step09 - Gatemate RISC-V Tutorial

### Description

This folder is step09 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step09 implements the 6 different branch instructions:

| instruction      | effect                                             |
|------------------|----------------------------------------------------|
| BEQ rs1,rs2,imm  | if(rs1 == rs2) PC <- PC+Bimm                       |
| BNE rs1,rs2,imm  | if(rs1 != rs2) PC <- PC+Bimm                       |
| BLT rs1,rs2,imm  | if(rs1 <  rs2) PC <- PC+Bimm (signed comparison)   |
| BGE rs1,rs2,imm  | if(rs1 >= rs2) PC <- PC+Bimm (signed comparison)   |
| BLTU rs1,rs2,imm | if(rs1 <  rs2) PC <- PC+Bimm (unsigned comparison) |
| BGEU rs1,rs2,imm | if(rs1 >= rs2) PC <- PC+Bimm (unsigned comparison) |

Implementation:
```verilog
   // The predicate for branch instructions
   reg takeBranch;
   always @(*) begin
      case(funct3)
        3'b000: takeBranch = (rs1 == rs2);
        3'b001: takeBranch = (rs1 != rs2);
        3'b100: takeBranch = ($signed(rs1) < $signed(rs2));
        3'b101: takeBranch = ($signed(rs1) >= $signed(rs2));
        3'b110: takeBranch = (rs1 < rs2);
        3'b111: takeBranch = (rs1 >= rs2);
        default: takeBranch = 1'b0;
      endcase
   end
```

The CPU executes a small assembly code that implements a 5-bit counter. The board LED's show the counter.

### Build FPGA Bitstream

```
step09$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                196
   Number of wire bits:           1628
   Number of public wires:          42
   Number of public wire bits:     750
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                450
     CC_ADDF                       103
     CC_BRAM_20K                     3
     CC_BUFG                         2
     CC_DFF                         38
     CC_IBUF                         3
     CC_LUT1                        37
     CC_LUT2                        29
     CC_LUT3                       142
     CC_LUT4                        52
     CC_MX4                         32
     CC_OBUF                         9
...
End of script. Logfile hash: 09aea2dc2a, CPU: user 0.11s system 0.60s, MEM: 28.06 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 24% 1x abc (0 sec), 14% 26x opt_expr (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step09$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
Label:          8
LEDS = 111xxxxx
ALUreg rd= 1 rs1= 0 rs2= 0 funct3=000
x1 <= 00000000000000000000000000000000
ALUimm rd= 2 rs1= 0 imm=32 funct3=000
x2 <= 00000000000000000000000000100000
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
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
x1 <= 00000000000000000000000000000111
LEDS = 11111000
^C** VVP Stop(0) **
** Flushing output streams.
** Current simulation time is 58817279 ticks.
> finish
** Continue **
```

### Board Programming
```
step09$ make prog
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