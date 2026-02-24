## Step23 - Gatemate RISC-V Tutorial

### Description

**Note** This step does not work yet. There is a issue with the Verilog flash driver and the Gatemate E1 board. This is discussed in [Issue 2]().

This folder is step23 of the popular FPGA tutorial ["From Blinker to RISCV"](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV) by BrunoLevy.

Step23 demonstrates how to load and run a native RISC-V 'C' program from SPI Flash. This is needed for larger programs that do not fit into the limited internal RAM of an FPGA. As an example program we re-use the same "Hello World" example program from step20.

In this step the author adds the following code changes to run s program from flash. The changes are slighly adjusted to move the flash offset a bit higher (from 128kB to 1MB), leaving more space for the Gatemate FPGA bitstream.

1. Update the `WAIT_INSTR` state SOC.v
To load code from the SPI flash, we must stay in WAIT_INSTR state until mem_rbusy is zero, indicating the flash data has beel loaded. In Verilog, a test for mem_rbusy is added as a condition before jumping to state EXECUTE:

```
   WAIT_INSTR: begin
      instr <= mem_rdata[31:2];
      rs1 <= RegisterBank[mem_rdata[19:15]];
      rs2 <= RegisterBank[mem_rdata[24:20]];
      if(!mem_rbusy) state <= EXECUTE;
   end
```

2. Initialize BRAM to jump to address 0x00900000

Address 0x00900000 corresponds to the address where the SPI flash is projected into the address space of our CPU (0x00800000 = 1 << 23), plus an offset of 1MB (0x100000). This offset of 1MB is necessary because we share the SPI Flash with the FPGA.
```
`include "../rtl-shared/riscv_assembly.v"
   initial begin
      LI(a0,32'h00900000);
      JR(a0);
   end
```

The assembly instructions in Verilog need the ../rtl-shared/riscv_assembly.v to be included.

3. Use a dedicated linker script for the RISC-V program

It is saved into `ldscritps-shared/spiflash0.ld`:
```
MEMORY {
   /* ------------------------------------------------------------------------------------------- */
   /* This section defines the physical layout of the target                                      */
   /* FLASH - defines a memory region named "FLASH"                                               */
   /* (RX) - sets memory as Read-only and eXecutable (typical for code stored in flash)           */
   /* ORIGIN = 0x00900000: start address. Flash is mapped to start at 9MB into the address space. */
   /* LENGTH = 0x100000: This is the size of the region set as 1MB.                               */
   /* ------------------------------------------------------------------------------------------- */
   FLASH (RX)  : ORIGIN = 0x00900000, LENGTH = 0x100000
}
SECTIONS {
   /* ------------------------------------------------------------------------------------------- */
   /* everything : creates an output section "everything"                                         */
   /*  . = ALIGN(4);: ensures the current location counter is aligned to a 4-byte boundary.       */
   /*                 Most CPUs require instructions to be word-aligned.                          */
   /* start.o (.text): instructs to put the .text section (the actual executable code) from the   */
   /*                  file start.o first. Ensures entry point is at the beginning of the flash.  */
   /* *(.*): This "catch-all" wildcard tells the linker to take all sections from all other input */
   /*        files and bundle them here (e.g. code, read-only data, any other defined segments).  */
   /* >FLASH - This tells linker to put "everthing" into FLASH memory                             */
   /* ------------------------------------------------------------------------------------------- */
    everything : {
	. = ALIGN(4);
	start.o (.text)
        *(.*)
    } >FLASH
}
```
4. In src-hello/hello.S, set section as "read-only"

We run "XIP" (eXecute In Place) from Flash. Setting `.section .rodata` (Read-Only Data) in hello.S tells the assembler/linker that the string is a constant and stays in the Flash memory.

```
.section .rodata
hello:
	.asciz "Gatemate E1 RISC-V: Hello World, running from Flash!\n"
```

#### RISC-V SoC Memory Map

| Base Address | End Address  | Size   | Target Device      | Access | Description                                              |
|:-------------|:-------------|:-------|:-------------------|:-------|:---------------------------------------------------------|
| `0x00000000` | `0x000017FF` | 6 KiB  | **Internal RAM**   | RW     | Bootloader, Stack Space (SP init: `0x17FC`)              |
| `0x00400004` | `0x00400007` | 4 B    | **GPIO LEDs**      | W      | `IO_LEDS` offset (Gatemate E1 LED D1..D8)                |
| `0x00400008` | `0x0040000B` | 4 B    | **UART Data**      | W      | `IO_UART_DAT` Transmit register, puchar writes here      |
| `0x00400010` | `0x00400013` | 4 B    | **UART Control**   | R      | `IO_UART_CNTL` (Bit 9: Busy status, checked by putchar)  |
| `0x00900000` | `0x009FFFFF` | 1 MiB  | **SPI Flash**      | RX     | Firmware/Code (Entry point `0x00900000`) Flash storage   |

**Notes:**
* **GP (Global Pointer):** Initialized to `0x00400000` for I/O access.
* **SP (Stack Pointer):** Initialized to `0x000017FC` (grows downwards).
* **Execution:** Hardware boots at `0x0`, runs Verilog-defined `LI/JR` bootloader, then jumps to Flash.1

### Build FPGA Bitstream

```
```
### Simulation

iVerilog:
```
```

### Board Programming
```
```
### Output
With the UART assigned to the E1 boards PMODB connector pins, the Digilent PMOD-UART converter receives the RISC-V program output, and we can display it in a terminal window.


