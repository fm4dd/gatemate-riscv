## Step07 - Gatemate RISC-V Tutorial

### Description

This folder is step07 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step07 implements the same small CPU test program as we had in the previous step06, but this time its written as a Verilog assembly program into the top Verlog module, which is much easier to read.

step06 test program:
```verilog
   initial begin
      PC = 0;
      MEM[0]  = 32'b0000000_00000_00000_000_00001_0110011; // add x1, x0, x0
      MEM[1]  = 32'b000000000001_00001_000_00001_0010011;  // addi x1, x1, 1
      MEM[2]  = 32'b000000000001_00001_000_00001_0010011;  // addi x1, x1, 1
      MEM[3]  = 32'b000000000001_00001_000_00001_0010011;  // addi x1, x1, 1
      MEM[4]  = 32'b000000000001_00001_000_00001_0010011;  // addi x1, x1, 1
      MEM[5]  = 32'b0000000_00000_00001_000_00010_0110011; // add x2, x1, x0
      MEM[6]  = 32'b0000000_00010_00001_000_00011_0110011; // add x3, x1, x2
      MEM[7]  = 32'b0000000_00011_00011_101_00011_0010011; // srli x3, x3, 3
      MEM[8]  = 32'b0000000_11111_00011_001_00011_0010011; // slli x3, x3, 31
      MEM[9]  = 32'b0100000_00101_00011_101_00011_0010011; // srai x3, x3, 5
      MEM[10] = 32'b0000000_11010_00011_101_00001_0010011; // srli x1, x3, 26
      MEM[11] = 32'b000000000001_00000_000_00000_1110011;  // ebreak
   end
```
step07 test program:
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

The CPU executes the small assembly test program. Same as in step06, the board LED's show the result of the ALU.

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
Info: 	              CPE_LT:    1017/  40960     2%
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
LEDS = 11000000
SYSTEM
SOC.v:192: $finish called at 19660799 (1s)
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
