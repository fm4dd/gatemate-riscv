## Step21 - Gatemate RISC-V Tutorial

### Description

This folder is step21 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step21 demonstrates how to compile a native RISC-V 'C' program, how to load and run it from the FPGA BRAM. The example  program sieve.c finds the first 31 prime numbers, and outputs the result to the UART.

### Build FPGA Bitstream

```
fm@nuc7fpga:~/fpga/projects/git/gatemate-riscv/step21$ make
make -C src-sieve
make[1]: Entering directory '/mnt/hgfs/fpga/projects/git/gatemate-riscv/step21/src-sieve'
...
/home/fm/fpga/projects/git/gatemate-riscv/riscv-toolchain/firmware_words/firmware_words sieve.bram.elf -ram 6144 -max_addr 6144 -out firmware.hex
   RAM SIZE=6144
   LOAD ELF: sieve.bram.elf
       max address=3209
Code size: 802 words ( total RAM size: 1536 words )
Occupancy: 52%
testing MAX_ADDR limit: 6144
   max_addr OK
   SAVE HEX: firmware.hex
make[1]: Leaving directory '/mnt/hgfs/fpga/projects/git/gatemate-riscv/step21/src-sieve'
cp src-sieve/firmware.hex .
/home/fm/cc-toolchain-linux/bin/yosys/yosys -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v ../rtl-shared/emmitter_uart.v; synth_gatemate -top SOC -vlog SOC_synth.v'

 /----------------------------------------------------------------------------\
 |                                                                            |
 |  yosys -- Yosys Open SYnthesis Suite                                       |
 |                                                                            |
 |  Copyright (C) 2012 - 2020  Claire Xenia Wolf <claire@yosyshq.com>         |
...
=== SOC ===

   Number of wires:                590
   Number of wire bits:           3187
   Number of public wires:          67
   Number of public wire bits:    1041
   Number of memories:               0
   Number of memory bits:            0
   Number of processes:              0
   Number of cells:               1214
     CC_ADDF                       170
     CC_BRAM_20K                     5
     CC_BUFG                         1
     CC_DFF                        106
     CC_IBUF                         3
     CC_LUT1                        37
     CC_LUT2                        50
     CC_LUT3                       388
     CC_LUT4                       444
     CC_OBUF                         9
     CC_PLL                          1
...
End of script. Logfile hash: 55b951fbf2, CPU: user 1.27s system 0.52s, MEM: 29.96 MB peak
Yosys 0.29+42 (git sha1 2004a9ff4, g++ 12.2.1 -Os)
Time spent: 31% 1x abc (0 sec), 14% 28x opt_expr (0 sec), ...
test -e ../gatemate-e1.ccf || exit
/home/fm/cc-toolchain-linux/bin/p_r/p_r -i SOC_synth.v -o SOC -ccf ../gatemate-e1.ccf +uCIO > SOC_pr.log
```
### Simulation
```
fm@nuc7fpga:~/fpga/projects/git/gatemate-riscv/step21$ make test
Running testbench simulation
test ! -e SOC.tb || rm SOC.tb
test ! -e SOC.vcd || rm SOC.vcd
/usr/bin/iverilog -DBENCH -o SOC.tb -s SOC_tb SOC_tb.v SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v ../rtl-shared/emmitter_uart.v
/usr/bin/vvp SOC.tb
LEDS = 111xxxxx
 1st prime: 2
 2nd prime: 3
 3rd prime: 5
 4th prime: 7
 5th prime: 11
 6th prime: 13
 7th prime: 17
 8th prime: 19
 9th prime: 23
10th prime: 29
11th prime: 31
12th prime: 37
13th prime: 41
14th prime: 43
15th prime: 47
16th prime: 53
17th prime: 59
18th prime: 61
19th prime: 67
20th prime: 71
21st prime: 73
22nd prime: 79
23rd prime: 83
24th prime: 89
25th prime: 97
26th prime: 101
27th prime: 103
28th prime: 107
29th prime: 109
30th prime: 113
31st prime: 127
checksum:
   1772A48F OK
^C** VVP Stop(0) **
** Flushing output streams.
** Current simulation time is 1318776 ticks.
> finish
** Continue **
```

### Board Programming
```
step21$ make prog
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
### Output
With the UART assigned to the E1 boards PMODB connector pins, the Digilent PMOD-UART converter receives the RISC-V program output, and we can display it in a terminal window. The terminal output runs at a bitrate of 833.333, falling short of the UART target speed of 1Mbaud (1.000.000). The root cause is discussed in [Issue #3](https://github.com/fm4dd/gatemate-riscv/issues/3). Setting the GTKTerm port speed to baudrate 800.000 is sufficient.

<img src="../images/step19-uart-terminal.png" width="480px">