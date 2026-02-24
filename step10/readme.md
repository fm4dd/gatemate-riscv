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
Info: 	              CPE_LT:    1253/  40960     3%
Info: 	              CPE_FF:      60/  40960     0%
Info: 	           CPE_RAMIO:     252/  40960     0%
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
LUI
x1 <= 11111111111111111111000000000000
ALUimm rd= 1 rs1= 1 imm=4294967295 funct3=110
x1 <= 11111111111111111111111111111111
LEDS = 00000000
SYSTEM
SOC.v:216: $finish called at 983039 (1s)
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
