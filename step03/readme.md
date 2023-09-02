## Step03 - Gatemate RISC-V Tutorial

### Description

This folder is step03 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step03 demonstrates how to use block ram (bram) as ROM to define and load bit patterns. This will become a building block for the processor components that are gradually added in the next steps. Here we use the block ram to store a 21-step LED bit pattern that the program will cycle through sequentially.

One change from the original code is the increase of allocated MEM storage from 5x20 bits to 5x4096 bits: ``` reg [4:0] MEM [0:4095];```. Without increasing the allocation, we won't get a CC_BRAM_20K object. The minimum allocation for CC_BRAM_20K is ``` reg [4:0] MEM [0:435];```, while ``` reg [4:0] MEM [0:4096];``` crosses the boundary and allocates the CC_BRAM_40K object.  For more information on Gatemate BRAM storage, see Cologne Chips Gatemate primitives library user guide (ug1001-gatemate1-primitives-library-latest.pdf), page77.
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

   reg [4:0] PC = 0;
   reg [4:0] MEM [0:4095];
   initial begin
       MEM[0]  = 5'b00000;
       MEM[1]  = 5'b00001;
       MEM[2]  = 5'b00010;
       MEM[3]  = 5'b00100;
       MEM[4]  = 5'b01000;
       MEM[5]  = 5'b10000;
       MEM[6]  = 5'b10001;
       MEM[7]  = 5'b10010;
       MEM[8]  = 5'b10100;
       MEM[9]  = 5'b11000;
       MEM[10] = 5'b11001;
       MEM[11] = 5'b11010;
       MEM[12] = 5'b11100;
       MEM[13] = 5'b11101;
       MEM[14] = 5'b11110;
       MEM[15] = 5'b11111;
       MEM[16] = 5'b11110;
       MEM[17] = 5'b11100;
       MEM[18] = 5'b11000;
       MEM[19] = 5'b10000;
       MEM[20] = 5'b00000;
   end

   reg [4:0] leds = 0;
   assign {LEDS[4:0], LEDS[7:5]} = {~leds, 3'b111};

   always @(posedge clk) begin
      leds <= MEM[PC];
      PC <= (!resetn || PC==20) ? 0 : (PC+1);
   end

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

Inside the always block, the 5-bit wide register variable PC will become the "program counter". Here it cycles through the memory address range.

### Build FPGA Bitstream
```
step03$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                 39
   Number of wire bits:            187
   Number of public wires:          12
   Number of public wire bits:      44
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                 81
     CC_ADDF                        27
     CC_BRAM_20K                     1
     CC_BUFG                         2
     CC_DFF                         28
     CC_IBUF                         3
     CC_LUT2                         5
     CC_LUT4                         6
     CC_OBUF                         9
...
End of script. Logfile hash: 889f59fad1, CPU: user 0.16s system 0.05s, MEM: 22.32 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 29% 1x abc (0 sec), 20% 15x read_verilog (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
fm@nuc7fpga:~/fpga/projects/git/gatemate-riscv/step03$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
LEDS = 11111111
LEDS = 11111110
LEDS = 11111101
LEDS = 11111011
LEDS = 11110111
LEDS = 11101111
LEDS = 11101110
LEDS = 11101101
LEDS = 11101011
LEDS = 11100111
LEDS = 11100110
LEDS = 11100101
LEDS = 11100011
LEDS = 11100010
LEDS = 11100001
LEDS = 11100000
```
Note the simulation stops after 16 patterns when all five LEDs are on. This can be changed in the SOC_tb.v testbench file.
### Board Programming
```
step03$ make prog
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