## Step04 - Gatemate RISC-V Tutorial

### Description

This folder is step04 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step04 implements the simplest RiSC-V instruction set architecture (ISA) called RV32I (32 bits base integer instruction set). The RISC-V instruction set is modular, and below are the core instructions. For more information, see [Episode II: the RV32I instruction set](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/DESIGN/FemtoRV32_II.md)

The RV32I (RISC-V 32-bit integer only) base instruction set has only 40 instructions. These are the instructions created in step04:
| # | Instruction | Syntax (Example) | Description |
| :--- | :--- | :--- | :--- |
| **01** | `ALUreg` | `add rd, rs1, rs2` | Performs arithmetic/logical operations between two registers. |
| **02** | `ALUimm` | `addi rd, rs1, imm` | Performs arithmetic/logical operations between a register and a constant. |
| **03** | `BRANCH` | `beq rs1, rs2, label` | Conditional jump to a label if the comparison between two registers is true. |
| **04** | `JAL` | `jal rd, label` | **Jump and Link**: A direct jump to a label, saving the return address in `rd`. |
| **05** | `JALR` | `jalr rd, offset(rs1)` | **Jump and Link Register**: An indirect jump to an address in a register. |
| **06** | `AUIPC` | `auipc rd, imm` | **Add Upper Immediate to PC**: Builds a PC-relative address for position-independent code. |
| **07** | `LUI` | `lui rd, imm` | **Load Upper Immediate**: Loads a 20-bit immediate into the upper bits of a register. |
| **08** | `LOAD` | `lw rd, offset(rs1)` | Loads a value from a memory address into a destination register. |
| **09** | `STORE` | `sw rs2, offset(rs1)` | Saves a value from a register into a specific memory address. |
| **10** | `SYSTEM` | `ecall` / `ebreak` | Used to call environment services or return control to a debugger. |

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
   wire [7:0] leds;

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
   end

   assign leds = isSYSTEM ? 8'b11111111 : { // all LED on ends the diagnostic pattern
       PC[0],    // LED 7 (Blinks as PC increments)
       isBranch, // LED 6
       isJAL,    // LED 5
       isJALR,   // LED 4
       isALUreg, // LED 3
       isALUimm, // LED 2
       isStore,  // LED 1
       isLoad    // LED 0
   };

   assign LEDS = ~leds; // Gatemate E1 LEDs use negative logic

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
      if(isSYSTEM) $finish();
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
This step initializes the memory with a few RISC-V instructions and see whether we can recognize them by lighting a different LED depending on the instruction. The LED's show the bit pattern of a light moving up through the instructions until all are on when SYSTEM is reached.

### Build FPGA Bitstream
```
$ make
/home/fm/oss-cad-suite/bin/yosys -ql log/synth.log -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -luttree -nomx8 -vlog net/SOC_synth.v; write_json net/SOC_synth.json'
Warning: Resizing cell port SOC.MEM.0.0.A_DO from 10 bits to 20 bits.
test -e ../gatemate-e1.ccf || exit
/home/fm/oss-cad-suite/bin/nextpnr-himbaechel --device=CCGM1A1 --json net/SOC_synth.json --write net/SOC_impl.v -o out=net/SOC_impl.txt -o ccf=../gatemate-e1.ccf --router router2 > log/impl.log
Info: Using uarch 'gatemate' for device 'CCGM1A1'
Info: Using timing mode 'WORST'
Info: Using operation mode 'SPEED'
...
Info: Device utilisation:
Info: 	            USR_RSTN:       0/      1     0%
Info: 	            CPE_COMP:       0/  20480     0%
Info: 	         CPE_CPLINES:       2/  20480     0%
Info: 	               IOSEL:      12/    162     7%
Info: 	                GPIO:      12/    162     7%
Info: 	               CLKIN:       1/      1   100%
Info: 	              GLBOUT:       1/      1   100%
Info: 	                 PLL:       0/      4     0%
Info: 	            CFG_CTRL:       0/      1     0%
Info: 	              SERDES:       0/      1     0%
Info: 	              CPE_LT:      85/  40960     0%
Info: 	              CPE_FF:      31/  40960     0%
Info: 	           CPE_RAMIO:      35/  40960     0%
Info: 	            RAM_HALF:       1/     64     1%
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
t/home/fm/oss-cad-suite/bin/vvp SOC.tb
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
SOC.v:106: $finish called at 4456447 (1s)
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
start addr: 00000000, end_addr: 00010000
Erasing: [==================================================] 100.00%
Done
Writing: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```
