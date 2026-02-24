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
A parameter SLOW provides a external value to define the speed. The output clock frequency is 2^SLOW. The Clockworks module is then inserted between the CLK signal of the board and the design, using an internal clk signal in step2.v:
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
Info: 	         CPE_CPLINES:       2/  20480     0%
Info: 	               IOSEL:      12/    162     7%
Info: 	                GPIO:      12/    162     7%
Info: 	               CLKIN:       1/      1   100%
Info: 	              GLBOUT:       1/      1   100%
Info: 	                 PLL:       0/      4     0%
Info: 	            CFG_CTRL:       0/      1     0%
Info: 	              SERDES:       0/      1     0%
Info: 	              CPE_LT:      41/  40960     0%
Info: 	              CPE_FF:      27/  40960     0%
Info: 	           CPE_RAMIO:       6/  40960     0%
Info: 	            RAM_HALF:       0/     64     0%
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
SOC_tb.v:26: $finish called at 15990785 (1s)
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
