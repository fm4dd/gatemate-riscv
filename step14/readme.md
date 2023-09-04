## Step14 - Gatemate RISC-V Tutorial

### Description

This folder is step14 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step14 is a second rework of the RISC-V application assembly code. It is changed to use the RISC-V ABI and pseudo-instructions. Even though all RISC-V registers are the same, the ABI calling convention assigns registers for certain tasks:
- register x1 for return address
- register x10..x17 for function parameters
- ...

See https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf, Table 18.2: RISC-V calling convention register usage. In [riscv_assembly.v](../rtl-shared/riscv_assembly.v), the ABI register name aliases are added:
```verilog
   localparam zero = x0;
   localparam ra   = x1;
   localparam sp   = x2;
   localparam gp   = x3;
   ...
   localparam t4   = x29;
   localparam t5   = x30;
   localparam t6   = x31;
```

Besides register names, the ABI also has pseudo-instruction names for common tasks, such NOP and RET for returning from a function. They were likewise added into [riscv_assembly.v](../rtl-shared/riscv_assembly.v)
``` verilog
/*
 * RISC-V pseudo-instructions
 */

task NOP;
   begin
      ADD(x0,x0,x0);
   end
endtask

...

task RET;
  begin
     JALR(x0,x1,0);
  end
endtask
```

Here is the updated assembly code inside the memory module of SOC.v, using ABI register names with pseudo instructions:

```verilog
   integer L0_   = 4;
   integer wait_ = 24;
   integer L1_   = 32;

   initial begin
      LI(a0,0);
   Label(L0_);
      ADDI(a0,a0,1);
      CALL(LabelRef(wait_));
      J(LabelRef(L0_));

      EBREAK();

   Label(wait_);
      LI(a1,1);
      SLLI(a1,a1,slow_bit);
   Label(L1_);
      ADDI(a1,a1,-1);
      BNEZ(a1,LabelRef(L1_));
      RET();

      endASM();
   end
```

### Build FPGA Bitstream

```
step14$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                429
   Number of wire bits:           3305
   Number of public wires:          71
   Number of public wire bits:    1638
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                913
     CC_ADDF                       142
     CC_BRAM_20K                     3
     CC_BUFG                         1
     CC_DFF                         85
     CC_IBUF                         3
     CC_LUT1                        37
     CC_LUT2                        19
     CC_LUT3                       167
     CC_LUT4                       447
     CC_OBUF                         9
...
End of script. Logfile hash: 1c8e70eda9, CPU: user 0.67s system 0.44s, MEM: 25.73 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 32% 1x abc (0 sec), 13% 27x opt_expr (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step14$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
Label:          4
Label:         24
Label:         32
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
** Current simulation time is 2124803 ticks.
> finish
** Continue **
```

### Board Programming
```
step14$ make prog
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