## Step13 - Gatemate RISC-V Tutorial

### Description

This folder is step13 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step13 removes the ```#(.SLOW(nnn))``` parameter in the Clockworks instantiation. This no longer generates a gearbox and directly wires the CLK signal of the board to the internal clk signal. The LED blink delay is now programmed into the RISC-V applications assembly code, using the Verilog local parameter "slow_bit" to differentiate between hardware execution vs. iVerilog simulation speed.

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
$ make
]/home/fm/oss-cad-suite/bin/yosys -ql log/synth.log -p 'read -sv SOC.v ../rtl-shared/clockworks.v ../rtl-shared/pll_gatemate.v; synth_gatemate -top SOC -luttree -nomx8 -vlog net/SOC_synth.v; write_json net/SOC_synth.json'
test -e ../gatemate-e1.ccf || exit
/home/fm/oss-cad-suite/bin/nextpnr-himbaechel --device=CCGM1A1 --json net/SOC_synth.json --write net/SOC_impl.v -o out=net/SOC_impl.txt -o ccf=../gatemate-e1.ccf --router router2 > log/impl.log
Info: Using uarch 'gatemate' for device 'CCGM1A1'
Info: Using timing mode 'WORST'
Info: Using operation mode 'SPEED'
...
Info: Device utilisation:
Info: 	            USR_RSTN:       0/      1     0%
Info: 	            CPE_COMP:       0/  20480     0%
Info: 	         CPE_CPLINES:       9/  20480     0%
Info: 	               IOSEL:      12/    162     7%
Info: 	                GPIO:      12/    162     7%
Info: 	               CLKIN:       1/      1   100%
Info: 	              GLBOUT:       1/      1   100%
Info: 	                 PLL:       0/      4     0%
Info: 	            CFG_CTRL:       0/      1     0%
Info: 	              SERDES:       0/      1     0%
Info: 	              CPE_LT:    1696/  40960     4%
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
Label:         20
Label:         28
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
SOC_tb.v:26: $finish called at 2098607 (1s)
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
