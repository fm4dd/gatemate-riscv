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
Info: 	         CPE_CPLINES:       5/  20480     0%
Info: 	               IOSEL:      12/    162     7%
Info: 	                GPIO:      12/    162     7%
Info: 	               CLKIN:       1/      1   100%
Info: 	              GLBOUT:       1/      1   100%
Info: 	                 PLL:       0/      4     0%
Info: 	            CFG_CTRL:       0/      1     0%
Info: 	              SERDES:       0/      1     0%
Info: 	              CPE_LT:    1367/  40960     3%
Info: 	              CPE_FF:      88/  40960     0%
Info: 	           CPE_RAMIO:     258/  40960     0%
Info: 	            RAM_HALF:       3/     64     4%
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
Label:          4
Label:         24
Label:         32
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
SOC_tb.v:26: $finish called at 2098847 (1s)
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
start addr: 00000000, end_addr: 00020000
Erasing: [==================================================] 100.00%
Done
Writing: [==================================================] 100.00%
Done
Wait for CFG_DONE DONE
```
