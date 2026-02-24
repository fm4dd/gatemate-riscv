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
   assign LEDS = ~leds;
```

The LED's now show the bit pattern of the execution state, cycling through state 1..3.

### Build FPGA Bitstream
```
$ make
/home/fm/oss-cad-suite/bin/yosys -ql log/synth.log -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -luttree -nomx8 -vlog net/SOC_synth.v; write_json net/SOC_synth.json'
Warning: Resizing cell port SOC.MEM.0.0.A_DO from 5 bits to 20 bits.
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
Info: 	              CPE_LT:      87/  40960     0%
Info: 	              CPE_FF:      34/  40960     0%
Info: 	           CPE_RAMIO:      31/  40960     0%
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
/home/fm/oss-cad-suite/bin/vvp SOC.tb
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
SOC.v:176: $finish called at 8650751 (1s)
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
