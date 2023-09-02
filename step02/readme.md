## Step02 - Gatemate RISC-V Tutorial

### Description

This folder is step02 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step02 implements a "clock divider" (also called a "gearbox") that counts on a large number of bits (and driving the counter with its most significant bit). The code is put into its own module [clockworks.v](../rtl-shared/clockworks.v), which got additional control code for reset handling and for PLL clock control. Since this module can be easily re-used throughout the next steps, its placed into the [rtl-shared](../rtl-shared) folder.

```verilog
module Clockworks 
(
   input  CLK,   // clock pin of the board
   input  RESET, // reset pin of the board
   output clk,   // (optionally divided) clock for the design.
   output resetn // (optionally timed) negative reset for the design (more on this later)
);
   parameter SLOW;
...
   reg [SLOW:0] slow_CLK = 0;
   always @(posedge CLK) begin
      slow_CLK <= slow_CLK + 1;
   end
   assign clk = slow_CLK[SLOW];
...
endmodule
```
A parameter SLOW provides a external value to define the spoeed. The output clock frequency is 2^SLOW. The Clockworks module is then inserted between the CLK signal of the board and the design, using an internal clk signal, as follows, in step2.v:
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

   // A blinker that counts on 5 bits, wired to 5 of 8 LEDs
   reg [4:0] count = 0;
   always @(posedge clk) begin
      count <= !resetn ? 0 : count + 1;
   end

   Clockworks #(
     .SLOW(21) // Divide clock frequency by 2^21
   )CW(
     .CLK(CLK),
     .RESET(~RESET), // gatemate RESET needs ~ to flip
     .clk(clk),
     .resetn(resetn)
   );

   // we assign 5 LEDS, and keep the remaining 3 off
   assign {LEDS[4:0], LEDS[7:5]} = {~count, 3'b111};
   assign TXD  = 1'b0; // UART is not used for now
endmodule

```
With the same counter as in step01 slowed down substantially, we can now see the bit pattern count cycling over the five LEDs.

### Build FPGA Bitstream
```
step02$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
4.49. Printing statistics.

=== SOC ===

   Number of wires:                 31
   Number of wire bits:            138
   Number of public wires:          12
   Number of public wire bits:      44
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                 78
     CC_ADDF                        27
     CC_BUFG                         2
     CC_DFF                         27
     CC_IBUF                         3
     CC_LUT1                         5
     CC_LUT2                         5
     CC_OBUF                         9
...
End of script. Logfile hash: ba3df645bd, CPU: user 0.11s system 0.06s, MEM: 22.36 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 28% 15x read_verilog (0 sec), 25% 1x abc (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
LEDS = 11111111
LEDS = 11111110
LEDS = 11111101
LEDS = 11111100
LEDS = 11111011
LEDS = 11111010
LEDS = 11111001
LEDS = 11111000
LEDS = 11110111
LEDS = 11110110
LEDS = 11110101
LEDS = 11110100
LEDS = 11110011
LEDS = 11110010
LEDS = 11110001
LEDS = 11110000
LEDS = 11101111
LEDS = 11101110
LEDS = 11101101
LEDS = 11101100
LEDS = 11101011
LEDS = 11101010
LEDS = 11101001
LEDS = 11101000
LEDS = 11100111
LEDS = 11100110
LEDS = 11100101
LEDS = 11100100
LEDS = 11100011
LEDS = 11100010
LEDS = 11100001
LEDS = 11100000
```

### Board Programming
```
step02$ make prog
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