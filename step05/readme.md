## Step05 - Gatemate RISC-V Tutorial

### Description

This folder is step05 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step05 implements the register bank and the state machine. For more information, see [Episode III: the register file](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/DESIGN/FemtoRV32_III.md). The register bank is implemented as follows:
```verilog
   // The registers bank
   reg [31:0] RegisterBank [0:31];
   reg [31:0] rs1;
   reg [31:0] rs2;
   wire [31:0] writeBackData;
   wire        writeBackEn;
   assign writeBackData = 0; // for now
   assign writeBackEn = 0;   // for now
```

In order to execute a instruction, four steps are needed:
1. fetch the instruction (```FETCH_INSTR```)
2. fetch the register rs1 and rs2 values (```FETCH_REGS```)
3. compute the instruction rs1 OP rs2 (```EXECUTE```)
4. store computation result in rd (```RegisterBank[rdId] <= writeBackData;```)

Steps 1., 2. and 3. are implemented by a state machine (```FETCH_INSTR->FETCH_REGS->EXECUTE-> FETCH_INSTR...```):

```verilog
   // The state machine

   localparam FETCH_INSTR = 0;
   localparam FETCH_REGS  = 1;
   localparam EXECUTE     = 2;
   reg [1:0] state = FETCH_INSTR;

   always @(posedge clk) begin
      if(!resetn) begin
         PC    <= 0;
         state <= FETCH_INSTR;
         instr <= 32'b0000000_00000_00000_000_00000_0110011; // NOP
      end else begin
         if(writeBackEn && rdId != 0) begin
            RegisterBank[rdId] <= writeBackData;
         end

         case(state)
           FETCH_INSTR: begin
              instr <= MEM[PC];
              state <= FETCH_REGS;
           end
           FETCH_REGS: begin
              rs1 <= RegisterBank[rs1Id];
              rs2 <= RegisterBank[rs2Id];
              state <= EXECUTE;
           end
           EXECUTE: begin
              if(!isSYSTEM) begin
                 PC <= PC + 1;
              end
              state <= FETCH_INSTR;
`ifdef BENCH
              if(isSYSTEM) $finish();
`endif
           end
         endcase
      end
   end

   assign leds = isSYSTEM ? 31 : (1 << state);
   assign {LEDS[4:0], LEDS[7:5]} = {~leds, 3'b111};
```

The LED's now show the bit pattern of the execution state, cycling through state 1..3.

### Build FPGA Bitstream
```
step05$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                 58
   Number of wire bits:            530
   Number of public wires:          27
   Number of public wire bits:     328
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                 99
     CC_ADDF                        31
     CC_BRAM_20K                     1
     CC_BUFG                         2
     CC_DFF                         34
     CC_IBUF                         3
     CC_LUT2                         3
     CC_LUT3                         7
     CC_LUT4                         9
     CC_OBUF                         9
...
End of script. Logfile hash: ca0d8b5292, CPU: user 0.12s system 0.14s, MEM: 26.41 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 26% 1x abc (0 sec), 16% 15x read_verilog (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step05$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
LEDS = 11111110
LEDS = 11111101
ALUreg rd= 1 rs1= 0 rs2= 0 funct3=000
LEDS = 11111011
LEDS = 11111110
LEDS = 11111101
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
LEDS = 11111011
LEDS = 11111110
LEDS = 11111101
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
LEDS = 11111011
LEDS = 11111110
LEDS = 11111101
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
LEDS = 11111011
LEDS = 11111110
LEDS = 11111101
ALUimm rd= 1 rs1= 1 imm=1 funct3=000
LEDS = 11111011
LEDS = 11111110
LEDS = 11100000
SYSTEM
```

### Board Programming
```
step05$ make prog
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