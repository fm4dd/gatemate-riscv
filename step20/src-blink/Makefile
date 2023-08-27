### ----------------------------------------------------------- ###
### Local Makefile for building the RISC-V native application.  ###
### Requires riscv-toolchain, linker script and firmware_words  ###
### hex conversion program. Creates the 'firmware.hex' output   ###
### for FPGA upload together with the bitstream.                ###
### ----------------------------------------------------------- ###

TOOLCHAINDIR=/home/fm/fpga/projects/git/gatemate-riscv/riscv-toolchain
RVLINKSCRIPT=/home/fm/fpga/projects/git/gatemate-riscv/ldscripts-shared/bram.ld
FW_WORDS_DIR=$(TOOLCHAINDIR)/firmware_words
ASFLAGS= -march=rv32i -mabi=ilp32 -mno-relax
LDFLAGS= -m elf32lriscv -nostdlib -norelax -T $(RVLINKSCRIPT)

all: firmware.hex

# Step-3: Convert the RISCV elf binary into an readmem() formatted hex file
# -------------------------------------------------------------------------
RAMSIZE=6144

firmware.hex: blinker.bram.elf
	$(FW_WORDS_DIR)/firmware_words $< -ram $(RAMSIZE) -max_addr $(RAMSIZE) -out $@

# Step-2: Link the object files into a RISCV elf binary
# -----------------------------------------------------
blinker.bram.elf: %.o
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-ld start.o wait.o blinker.o $(LDFLAGS) -o $@

# Step-1: build object files (.o) from assembler source files (.S) 
# ----------------------------------------------------------------
%o:
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-as $(ASFLAGS) start.S -o start.o
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-as $(ASFLAGS) wait.S -o wait.o
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-as $(ASFLAGS) blinker.S -o blinker.o

clean:
	rm -f *.o *.hex *.elf

.SECONDARY:
.PHONY: all clean
