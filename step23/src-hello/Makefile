### ----------------------------------------------------------- ###
### Local Makefile for building the RISC-V native application.  ###
### Requires riscv-toolchain, linker script and firmware_words  ###
### hex conversion program. Creates the 'firmware.hex' output   ###
### for simulation, and hello.spiflash0.bin for Flash upload.   ###
### ----------------------------------------------------------- ###

TOOLCHAINDIR=/home/fm/fpga/projects/git/gatemate-riscv/riscv-toolchain
LDMEMSCRIPT=/home/fm/fpga/projects/git/gatemate-riscv/ldscripts-shared/spiflash0.ld
BRAMSCRIPT=/home/fm/fpga/projects/git/gatemate-riscv/ldscripts-shared/bram.ld
FW_WORDS_DIR=$(TOOLCHAINDIR)/firmware_words
# RV32I_LIBGCC=$(TOOLCHAINDIR)/lib/gcc/riscv64-unknown-elf/8.3.0/rv32i/ilp32/libgcc.a

ASFLAGS= -march=rv32i -mabi=ilp32 -mno-relax
LDFLAGS= -m elf32lriscv -nostdlib -norelax

all: hello.spiflash0.bin firmware.hex

# Step-4: Convert the RISCV elf binary into an readmem() formatted hex file
# We only need the firmware.hex file for the simulation testbench
# --------------------------------------------------------------------------
RAMSIZE=6144

firmware.hex:
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-ld -T $(BRAMSCRIPT) $(LDFLAGS) wait.o start.o hello.o putchar.o -o hello.bram.elf
	$(FW_WORDS_DIR)/firmware_words hello.bram.elf -ram $(RAMSIZE) -max_addr $(RAMSIZE) -out $@

# Step-3: Convert the RISCV elf executable into a flat binary for FPGA flash upload
# ---------------------------------------------------------------------------------
hello.spiflash0.bin: hello.spiflash0.elf
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-objcopy $< $@ -O binary

# Step-2: Link the object files into a RISCV elf binary
# -----------------------------------------------------
hello.spiflash0.elf: %.o
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-ld -T $(LDMEMSCRIPT) $(LDFLAGS) wait.o start.o hello.o putchar.o -o $@

# Step-1: build object files (.o) from assembler source files (.S) 
# ----------------------------------------------------------------
%o:
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-as $(ASFLAGS) start.S -o start.o
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-as $(ASFLAGS) wait.S -o wait.o
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-as $(ASFLAGS) putchar.S -o putchar.o
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-as $(ASFLAGS) hello.S -o hello.o

clean:
	rm -f *.o *.hex *.elf *.bin

.SECONDARY:
.PHONY: all clean

