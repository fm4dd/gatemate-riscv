## readme_start-S.md
### Overview
The file start.S is the assembly entry point (often called a crt0 or startup stub) for the RISC-V soft-core processor. It initializes the minimal execution environment required to run C code, specifically by setting up the Global Pointer and Stack Pointer before jumping to main().
#### Source Code
```assembly
.equ IO_BASE, 0x400000
.section .text
.globl start
start:
li   gp,IO_BASE
li   sp,0x1800
call main
ebreak
```
---
### Line-by-Line Analysis
1. I/O Base Definition
 * Code: .equ IO_BASE, 0x400000
 * Purpose: Defines the base address for Memory Mapped I/O (MMIO).
 * Hardware Context: In this FPGA design, peripherals (like UART, LEDs, or SPI) are mapped starting at 0x400000. By defining this as a constant, the software can interact with hardware by reading/writing to this memory range.
2. Segment Declaration
 * Code: .section .text and .globl start
 * Purpose: #     * .text specifies that the following instructions should be placed in the executable code region of the memory.
 * .globl start exports the start symbol so the Linker Script can find it and set it as the CPU's first instruction after reset.
3. Global Pointer (gp) Initialization
 * Code: li gp, IO_BASE
 * Purpose: Loads the address 0x400000 into the gp (Global Pointer) register.
 * Optimization: In RISC-V, the gp register allows the CPU to access I/O registers using a single "offset" instruction rather than needing to load a full 32-bit address every time it wants to toggle a pin.
4. Stack Pointer (sp) Initialization
 * Code: li sp, 0x1800
 * Purpose: Sets the stack to start at 6 KB (0x1800).
 * Hardware Constraint: This confirms the 6 KB BRAM limit for this specific iCE40HX1K project. The stack grows downward from 0x1800 toward 0x0000. This 6 KB represents exactly 12 out of the 16 available 4-kbit EBR blocks on the chip.
5. Execution Handover
 * Code: call main
 * Purpose: Jumps to the main() function in your C code. It saves the current address in the Link Register (ra), though embedded entry points typically do not expect main to return.
6. Debug Break
 * Code: ebreak
 * Purpose: Acts as a safety net. If main() returns or crashes, the CPU hits this instruction, which pauses execution. This is useful when debugging via JTAG or a simulator.
---
#### Hardware Summary for iCE40HX1K
| Resource | Address / Value | Notes |
| :--- | :--- | :--- |
| Available BRAM | 8 KB (Total) | 16 EBR blocks |
| Project Allocation | 6 KB (0x1800) | 12 EBR blocks |
| I/O Mapping | 0x400000 | MMIO Base Address |

For Gatemate FPGA, we can expand the project allocation, e.g. as below:

### Suggested Gatemate CCGM1A1 Memory Layout:

#### Hardware Summary: Cologne Chip GateMate CCGM1A1
| Resource | Address / Value | Notes |
| :--- | :--- | :--- |
| Available BRAM | 160 KB (Total) | 32 blocks (40k-bit each) |
| Project Allocation | 128 KB (0x20000) | 25 blocks used for Code/Data |
| Stack Pointer (sp) | 0x20000 | Top of the 128 KB allocation |
| I/O Mapping | 0x400000 | MMIO Base Address |

#### 1. Project Allocation in Gatemate: 128 KB
* aligns memory to a "power of two" boundary.
* Code/Data Space: 0x00000 to 0x1FFFF.
* uses 25x40kb BRAM (7x40kb reserve)

This should be large enough to hold a decent C-program, a small file system, or a large look-up table (LUT) for signal processing.

#### 2. Stack Pointer Address
 * For 64KB, the stack pointer is 0x10000
 * for 128KB, he stack pointer is 0x20000
 * For 6KB, the stack pointer is 0x1800 (original project value)

E.g if we want to use  128KB, we set the following line in start.S for GateMate: `li sp, 0x20000`.

Because the stack grows downward, it will have the full 128 KB to share with your global variables and code.
Unlike the cramped 6 KB on the iCE40, this allows for deep recursion and large local arrays in C.

#### 3. Reserved BRAM (32 KB)
The remaining 32 KB (7 blocks) are left unmapped, e.g. to be used in Verilog.

### Example 128KB start.S source code for Gatemate CCGM1A1
```assembly
.equ IO_BASE, 0x400000
.section .text
.globl start
start:
li   gp,IO_BASE
li   sp,0x20000    # Set stack pointer to 128 KB
call main
ebreak
```

#### 4. set the RAM size in src/Makefile
 * 64KB: RAM = 65,536
 * 128KB: RAM = 131,072

This value will then be used by the `firmware_words` program.

#### 5. Set the RAM size in linker scripts 

E.g. we set it in /ldscripts-shared/bram.ld:

```
MEMORY
{
   BRAM (RWX) : ORIGIN = 0x0000, LENGTH = 0x20000  /* 128kB RAM */
}
SECTIONS
{
    everything :
    {
	. = ALIGN(4);
	start.o (.text)
        *(.*)
    } >BRAM
}
```
