## Step06 - Gatemate RISC-V Tutorial

### Description

This folder is step06 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step06 implements the arithmetic logic unit (ALU). For more information, see [Episode IV: the ALU and the predicates](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/DESIGN/FemtoRV32_IV.md).

The ALU takes two inputs aluIn1 and aluIn2, computes aluIn1 OP aluIn2, and stores the result in aluOut:
```verilog
   // The ALU
   wire [31:0] aluIn1 = rs1;
   wire [31:0] aluIn2 = isALUreg ? rs2 : Iimm;
   reg [31:0] aluOut;
   wire [4:0] shamt = isALUreg ? rs2[4:0] : instr[24:20]; // shift amount
```
The ALU is implemented as follows:
```verilog
   // ADD/SUB/ADDI:
   // funct7[5] is 1 for SUB and 0 for ADD. We need also to test instr[5]
   // to make the difference with ADDI
   //
   // SRLI/SRAI/SRL/SRA:
   // funct7[5] is 1 for arithmetic shift (SRA/SRAI) and
   // 0 for logical shift (SRL/SRLI)
   always @(*) begin
      case(funct3)
        3'b000: aluOut = (funct7[5] & instr[5]) ?
                         (aluIn1 - aluIn2) : (aluIn1 + aluIn2);
        3'b001: aluOut = aluIn1 << shamt;
        3'b010: aluOut = ($signed(aluIn1) < $signed(aluIn2));
        3'b011: aluOut = (aluIn1 < aluIn2);
        3'b100: aluOut = (aluIn1 ^ aluIn2);
        3'b101: aluOut = funct7[5]? ($signed(aluIn1) >>> shamt) :
                         ($signed(aluIn1) >> shamt);
        3'b110: aluOut = (aluIn1 | aluIn2);
        3'b111: aluOut = (aluIn1 & aluIn2);
      endcase
   end

```

The CPU executes a small code block stored MEM. The board LED's show the result of the ALU on the LEDs.

### Build FPGA Bitstream
```
step06$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                332
   Number of wire bits:           1884
   Number of public wires:          32
   Number of public wire bits:     492
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
End of script. Logfile hash: 3e617aa99b, CPU: user 0.63s system 0.22s, MEM: 27.16 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 28% 1x abc (0 sec), 14% 29x opt_expr (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step06$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
LEDS = 111xxxxx
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
step06$ make prog
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