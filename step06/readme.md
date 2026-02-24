## Step06 - Gatemate RISC-V Tutorial

### Description

This folder is step06 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step06 implements the arithmetic logic unit (ALU). For more information, see [Episode IV: the ALU and the predicates](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/DESIGN/FemtoRV32_IV.md). The RISCV core implementation reached 20 instructions.

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
$ make
/home/fm/oss-cad-suite/bin/yosys -ql log/synth.log -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -luttree -nomx8 -vlog net/SOC_synth.v; write_json net/SOC_synth.json'
test -e ../gatemate-e1.ccf || exit
/home/fm/oss-cad-suite/bin/nextpnr-himbaechel --device=CCGM1A1 --json net/SOC_synth.json --write net/SOC_impl.v -o out=net/SOC_impl.txt -o ccf=../gatemate-e1.ccf --router router2 > log/impl.log
Info: Using uarch 'gatemate' for device 'CCGM1A1'
Info: Using timing mode 'WORST'
Info: Using operation mode 'SPEED'
...
Info: Device utilisation:
Info: 	            USR_RSTN:       0/      1     0%
Info: 	            CPE_COMP:       0/  20480     0%
Info: 	         CPE_CPLINES:       4/  20480     0%
Info: 	               IOSEL:      12/    162     7%
Info: 	                GPIO:      12/    162     7%
Info: 	               CLKIN:       1/      1   100%
Info: 	              GLBOUT:       1/      1   100%
Info: 	                 PLL:       0/      4     0%
Info: 	            CFG_CTRL:       0/      1     0%
Info: 	              SERDES:       0/      1     0%
Info: 	              CPE_LT:     999/  40960     2%
Info: 	              CPE_FF:      40/  40960     0%
Info: 	           CPE_RAMIO:     242/  40960     0%
Info: 	            RAM_HALF:       3/     64     4%
...
Info: Program finished normally.
/home/fm/oss-cad-suite/bin/gmpack --input net/SOC_impl.txt --bit SOC.bit
```
### Simulation
```
$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/home/fm/oss-cad-suite/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/home/fm/oss-cad-suite/bin/vvp SOC.tb
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
LEDS = 11000000
SYSTEM
SOC.v:220: $finish called at 18087935 (1s)
```

### Board Programming
```
$ make prog
Programming E1 SPI Config:
/home/fm/oss-cad-suite/bin/openFPGALoader  -b gatemate_evb_spi SOC.bit
empty
Jtag frequency : requested 6.00MHz    -> real 6.00MHz   
JEDEC ID: 0xc22817
Detected: Macronix MX25R6435F 128 sectors size: 64Mb
00000000 00000000 00000000 00
start addr: 00000000, end_addr: 00020000
Erasing: [==================================================] 100.00%
Done
Writing: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```
