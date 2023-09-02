## Step10 - Gatemate RISC-V Tutorial

### Description

This folder is step10 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step10 implements the LUI and AUIPC instructions:

| instruction   | effect          |
|---------------|-----------------|
| LUI rd, imm   | rd <= Uimm      |
| AUIPC rd, imm | rd <= PC + Uimm |

The simple assembly test code below verifies the implementation works. Its a simply blinky:
```verilog
   // The predicate for branch instructions
   reg takeBranch;
   always @(*) begin
      case(funct3)
        3'b000: takeBranch = (rs1 == rs2);
        3'b001: takeBranch = (rs1 != rs2);
        3'b100: takeBranch = ($signed(rs1) < $signed(rs2));
        3'b101: takeBranch = ($signed(rs1) >= $signed(rs2));
        3'b110: takeBranch = (rs1 < rs2);
        3'b111: takeBranch = (rs1 >= rs2);
        default: takeBranch = 1'b0;
      endcase
   end
```

The CPU runs one LUI instruction. The board LED's show the execution data.

### Build FPGA Bitstream

Note: Because of an [issue](https://github.com/fm4dd/gatemate-riscv/issues/1) with Cologne Chip 'p_r' executable, this step10 uses a local constraints file instead of the global one.
```
step10$ make
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -vlog SOC_synth.v'
 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                406
   Number of wire bits:           2423
   Number of public wires:          37
   Number of public wire bits:     559
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:                878
     CC_ADDF                       168
     CC_BRAM_20K                     3
     CC_BUFG                         2
     CC_DFF                         59
     CC_IBUF                         3
     CC_LUT1                        37
     CC_LUT2                        32
     CC_LUT3                       283
     CC_LUT4                       252
     CC_MX4                         30
     CC_OBUF                         9
...
End of script. Logfile hash: c6cb2d2ee8, CPU: user 0.89s system 0.25s, MEM: 29.06 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 27% 1x abc (0 sec), 15% 30x opt_expr (0 sec), ...
test -e gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
step10$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v
/usr/bin/vvp SOC.tb
LEDS = 111xxxxx
LUI
x1 <= 11111111111111111111000000000000
ALUimm rd= 1 rs1= 1 imm=4294967295 funct3=110
x1 <= 11111111111111111111111111111111
LEDS = 11100000
SYSTEM
```

### Board Programming
```
step10$ make prog
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