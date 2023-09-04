## Step13 - Gatemate RISC-V Tutorial

### Description

This folder is step13 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step13 removes the ```#(.SLOW(nnn))``` parameter in the Clockworks instantiation. This no longer generates a gearbox and directly wires the CLK signal of the board to the internal clk signal. The LED blink delay is now programmed into the RISC-V applications assembly code, using the Verlog local parameter "slow_bit" to differentiate between hardware execution vs. iVerlilog simulation speed.

```verilog
`ifdef BENCH
   localparam slow_bit=15;
`else
   localparam slow_bit=19;
`endif

...
   integer L0_   = 4;
   integer wait_ = 20;
   integer L1_   = 28;

   initial begin
      ADD(x10,x0,x0);
   Label(L0_);
      ADDI(x10,x10,1);
      JAL(x1,LabelRef(wait_)); // call(wait_)
      JAL(zero,LabelRef(L0_)); // jump(l0_)

      EBREAK(); // I keep it systematically
                // here in case I change the program.

   Label(wait_);
      ADDI(x11,x0,1);
      SLLI(x11,x11,slow_bit);
   Label(L1_);
      ADDI(x11,x11,-1);
      BNE(x11,x0,LabelRef(L1_));
      JALR(x0,x1,0);

      endASM();
   end
```
### Build FPGA Bitstream

```
step13$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                585
   Number of wire bits:           4253
   Number of public wires:          59
   Number of public wire bits:    1257
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:               1371
     CC_ADDF                       352
     CC_BRAM_20K                     3
     CC_BUFG                         1
     CC_DFF                         85
     CC_IBUF                         3
     CC_LUT1                       101
     CC_LUT2                        58
     CC_LUT3                       294
     CC_LUT4                       435
     CC_MX4                         30
     CC_OBUF                         9
...
End of script. Logfile hash: 95b0ca000f, CPU: user 0.49s system 1.08s, MEM: 32.81 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 28% 1x abc (0 sec), 16% 30x opt_expr (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step13$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
Label:          4
Label:         20
Label:         28
LEDS = 111xxxxx
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
^C** VVP Stop(0) **
** Flushing output streams.
** Current simulation time is 7823913 ticks.
> finish
** Continue **
```

### Board Programming
```
step13$ make prog
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