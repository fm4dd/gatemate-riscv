## Step01 - Gatemate RISC-V Tutorial

### Description

This folder is step01 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step01 implements the most basic Verilog module that helps to verify the toolchain, the programming steps, and the signal assignment.

```verilog
   module SOC (
       input  CLK,        
       input  RESET,      
       output [7:0] LEDS, 
       input  RXD,        
       output TXD         
   );

   reg [4:0] count = 0;
   always @(posedge CLK) begin
      count <= count + 1;
   end
   assign LEDS[4:0] = ~count; // ~ to invert data
   assign LEDS[7:5] = 3'b111; // turn off LED5..7
   assign TXD  = 1'b0;        // not used for now

   endmodule

```
Because the tutorial was originally written for a Lattice Icestick, it only uses five onboard user LEDs. On the Gatemate E1 board we have eight user LED's LD1..8, however they are connected with "negative" logic, e.g. a '1' signal turns the LED off. I connected all eight LEDs, with signals negated and the remaining 3 LED's turned off. For experimentation, they can easily be enabled for additional state output.

The code above creates a counter, directly driven by the 10MHz clock signal feeding into the Gatemate E1 board. A count at such a high frequency is too fast for the human eye, and all five LED's appear to be "on".

### Build FPGA Bitstream
```
step01$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...

-- Running command `read -sv SOC.v ; synth_gatemate -top SOC -vlog SOC_synth.v' --

1. Executing Verilog-2005 frontend: SOC.v
Parsing SystemVerilog input from `SOC.v' to AST representation.
Storing AST representation for module `$abstract\SOC'.
Successfully finished Verilog frontend.
...

2.49. Printing statistics.

=== SOC ===

   Number of wires:                 18
   Number of wire bits:             41
   Number of public wires:           6
   Number of public wire bits:      17
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                 28
     CC_ADDF                         5
     CC_BUFG                         1
     CC_DFF                          5
     CC_IBUF                         3
     CC_LUT1                         5
     CC_OBUF                         9

2.50. Executing CHECK pass (checking for obvious problems).
Checking module SOC...
Found and reported 0 problems.

...

End of script. Logfile hash: 8e76e8f38a, CPU: user 0.04s system 0.09s, MEM: 21.95 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 32% 1x abc (0 sec), 31% 13x read_verilog (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step01$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v 
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
step01$ make prog
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