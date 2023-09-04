## Step15 - Gatemate RISC-V Tutorial

### Description

This folder is step15 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step15 implements five LOAD instructions:

 | Instruction     | Effect                                                       |
 |-----------------|--------------------------------------------------------------|
 | LW(rd,rs1,imm)  | Load word at address (rs1+imm) into rd                       |
 | LBU(rd,rs1,imm) | Load byte at address (rs1+imm) into rd                       |
 | LHU(rd,rs1,imm) | Load half-word at address (rs1+imm) into rd                  |
 | LB(rd,rs1,imm)  | Load byte at address (rs1+imm) into rd then sign extend      |
 | LH(rd,rs1,imm)  | Load half-word at address (rs1+imm) into rd then sign extend |

This step also updates the state machine for LOAD and WAIT_DATA.

The updated processor instruction code gets tested with a new RISC-V assembly application using the just implemented LOAD function. The assembly program below initializes values in four words at address 400, and loads them in a loop to register a0 (x10). This register is connected to the LEDs, and the delay loop (wait function) slows it down see the changes at human speed.

```verilog
   integer L0_   = 8;
   integer wait_ = 32;
   integer L1_   = 40;

   initial begin
      LI(s0,0);
      LI(s1,16);
   Label(L0_);
      LB(a0,s0,400); // LEDs are plugged on a0 (=x10)
      CALL(LabelRef(wait_));
      ADDI(s0,s0,1);
      BNE(s0,s1, LabelRef(L0_));
      EBREAK();

   Label(wait_);
      LI(t0,1);
      SLLI(t0,t0,slow_bit);
   Label(L1_);
      ADDI(t0,t0,-1);
      BNEZ(t0,LabelRef(L1_));
      RET();

      endASM();

      // Note: index 100 (word address)
      //     corresponds to
      // address 400 (byte address)
      MEM[100] = {8'h4, 8'h3, 8'h2, 8'h1};
      MEM[101] = {8'h8, 8'h7, 8'h6, 8'h5};
      MEM[102] = {8'hc, 8'hb, 8'ha, 8'h9};
      MEM[103] = {8'hff, 8'hf, 8'he, 8'hd};
   end
```

### Build FPGA Bitstream

```
step15$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                412
   Number of wire bits:           3192
   Number of public wires:          76
   Number of public wire bits:    1777
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                812
     CC_ADDF                       151
     CC_BRAM_20K                     3
     CC_BUFG                         1
     CC_DFF                         85
     CC_IBUF                         3
     CC_LUT1                        37
     CC_LUT2                        14
     CC_LUT3                       277
     CC_LUT4                       200
     CC_MX4                         32
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
step15$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
Label:          8
Label:         32
Label:         40
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
LEDS = 11100000
```

### Board Programming
```
step15$ make prog
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