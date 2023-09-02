## Step04 - Gatemate RISC-V Tutorial

### Description

This folder is step04 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step04 implements the simplest RiSC-V instruction set architecture (ISA) called RV32I (32 bits base integer instruction set). The RISC-V instruction set is modular, and below are the core instructions. For more information, see [Episode II: the RV32I instruction set](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/DESIGN/FemtoRV32_II.md)
```verilog
module SOC (
    input  CLK,        // E1 system clock
    input  RESET,      // E1 user button
    output [7:0] LEDS, // E1 onboard LEDs
    input  RXD,        // UART receive
    output TXD         // UART transmit
);

   wire clk;    // internal clock
   wire resetn; // internal reset signal, goes low on reset

   reg [31:0] MEM [0:255];
   reg [31:0] PC;       // program counter
   reg [31:0] instr;    // current instruction
   wire [4:0] leds;

   initial begin
      PC = 0;
      // add x0, x0, x0
      //                   rs2   rs1  add  rd   ALUREG
      instr = 32'b0000000_00000_00000_000_00000_0110011;
      // add x1, x0, x0
      //                    rs2   rs1  add  rd  ALUREG
      MEM[0] = 32'b0000000_00000_00000_000_00001_0110011;
      // addi x1, x1, 1
      //             imm         rs1  add  rd   ALUIMM
      MEM[1] = 32'b000000000001_00001_000_00001_0010011;
      // addi x1, x1, 1
      //             imm         rs1  add  rd   ALUIMM
      MEM[2] = 32'b000000000001_00001_000_00001_0010011;
      // addi x1, x1, 1
      //             imm         rs1  add  rd   ALUIMM
      MEM[3] = 32'b000000000001_00001_000_00001_0010011;
      // addi x1, x1, 1
      //             imm         rs1  add  rd   ALUIMM
      MEM[4] = 32'b000000000001_00001_000_00001_0010011;
      // lw x2,0(x1)
      //             imm         rs1   w   rd   LOAD
      MEM[5] = 32'b000000000000_00001_010_00010_0000011;
      // sw x2,0(x1)
      //             imm   rs2   rs1   w   imm  STORE
      MEM[6] = 32'b000000_00010_00001_010_00000_0100011;

      // ebreak
      //                                        SYSTEM
      MEM[7] = 32'b000000000001_00000_000_00000_1110011;

   end

   // See the table P. 105 in RISC-V manual

   // The 10 RISC-V instructions
   wire isALUreg  =  (instr[6:0] == 7'b0110011); // rd <- rs1 OP rs2   
   wire isALUimm  =  (instr[6:0] == 7'b0010011); // rd <- rs1 OP Iimm
   wire isBranch  =  (instr[6:0] == 7'b1100011); // if(rs1 OP rs2) PC<-PC+Bimm
   wire isJALR    =  (instr[6:0] == 7'b1100111); // rd <- PC+4; PC<-rs1+Iimm
   wire isJAL     =  (instr[6:0] == 7'b1101111); // rd <- PC+4; PC<-PC+Jimm
   wire isAUIPC   =  (instr[6:0] == 7'b0010111); // rd <- PC + Uimm
   wire isLUI     =  (instr[6:0] == 7'b0110111); // rd <- Uimm   
   wire isLoad    =  (instr[6:0] == 7'b0000011); // rd <- mem[rs1+Iimm]
   wire isStore   =  (instr[6:0] == 7'b0100011); // mem[rs1+Simm] <- rs2
   wire isSYSTEM  =  (instr[6:0] == 7'b1110011); // special

   // The 5 immediate formats
   wire [31:0] Uimm={    instr[31],   instr[30:12], {12{1'b0}}};
   wire [31:0] Iimm={{21{instr[31]}}, instr[30:20]};
   wire [31:0] Simm={{21{instr[31]}}, instr[30:25],instr[11:7]};
   wire [31:0] Bimm={{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0};
   wire [31:0] Jimm={{12{instr[31]}}, instr[19:12],instr[20],instr[30:21],1'b0};

   // Source and destination registers
   wire [4:0] rs1Id = instr[19:15];
   wire [4:0] rs2Id = instr[24:20];
   wire [4:0] rdId  = instr[11:7];

   // function codes
   wire [2:0] funct3 = instr[14:12];
   wire [6:0] funct7 = instr[31:25];

   always @(posedge clk) begin
      if(!resetn) begin
	     PC <= 0;
	    instr <= 32'b0000000_00000_00000_000_00000_0110011; // NOP
      end
      else if(!isSYSTEM) begin
	     instr <= MEM[PC];
	     PC <= PC+1;
      end
`ifdef BENCH
      if(isSYSTEM) $finish();
`endif
   end

   assign leds = isSYSTEM ? 31 : {PC[0],isALUreg,isALUimm,isStore,isLoad};
   assign {LEDS[4:0], LEDS[7:5]} = {~leds, 3'b111};

`ifdef BENCH
   always @(posedge clk) begin
      $display("PC=%0d",PC);
      case (1'b1)
	     isALUreg: $display("ALUreg rd=%d rs1=%d rs2=%d funct3=%b",
                            rdId, rs1Id, rs2Id, funct3);
	     isALUimm: $display("ALUimm rd=%d rs1=%d imm=%0d funct3=%b",
                            rdId, rs1Id, Iimm, funct3);
	     isBranch: $display("BRANCH");
	     isJAL:    $display("JAL");
	     isJALR:   $display("JALR");
	     isAUIPC:  $display("AUIPC");
	     isLUI:    $display("LUI");
	     isLoad:   $display("LOAD");
	     isStore:  $display("STORE");
         isSYSTEM: $display("SYSTEM");
      endcase
   end
`endif

   // Gearbox and reset circuitry.
   Clockworks #(
     .SLOW(21)         // Divide clock frequency by 2^21
   )CW(
     .CLK(CLK),
     .RESET(~RESET),   // Gatemate RESET needs ~ to flip
     .clk(clk),
     .resetn(resetn)
   );

   assign TXD  = 1'b0; // not used for now
endmodule

```
The LED's now show the bit pattern of a light moving up, followed by the next light until all are on, then the light pattern reverses until all are off again, cycling over the five LEDs.

### Build FPGA Bitstream
```
step04$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                 50
   Number of wire bits:            491
   Number of public wires:          23
   Number of public wire bits:     288
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                 90
     CC_ADDF                        30
     CC_BRAM_20K                     1
     CC_BUFG                         2
     CC_DFF                         31
     CC_IBUF                         3
     CC_LUT2                         1
     CC_LUT3                         1
     CC_LUT4                        12
     CC_OBUF                         9
...
End of script. Logfile hash: 04e9818ed1, CPU: user 0.36s system 0.13s, MEM: 26.19 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 39% 1x abc (0 sec), 20% 15x read_verilog (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log

```
### Simulation
```
step04$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
LEDS = 11110111
PC=0
ALUreg rd= 0 rs1= 0 rs2= 0 funct3=000
LEDS = 11100111
PC=1
ALUreg rd= 1 rs1= 0 rs2= 0 funct3=000
LEDS = 11111011
PC=2
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
LEDS = 11101011
PC=3
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
LEDS = 11111011
PC=4
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
LEDS = 11101011
PC=5
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
LEDS = 11111110
PC=6
LOAD
LEDS = 11101101
PC=7
STORE
LEDS = 11100000
PC=8
SYSTEM
```

### Board Programming
```
step04$ make prog
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