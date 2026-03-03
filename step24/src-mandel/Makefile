### ----------------------------------------------------------- ###
### Local Makefile for building the RISC-V native application.  ###
### Requires riscv-toolchain, linker script and elf-objcopy     ###
### bin conversion program. Creates the 'firmware.bin' output   ###
### for separate Flash upload before programming the FPGA.      ###
### ----------------------------------------------------------- ###
TOOLCHAINDIR=/home/fm/fpga/projects/git/gatemate-riscv/riscv-toolchain
RVLINKSCRIPT=/home/fm/fpga/projects/git/gatemate-riscv/ldscripts-shared/spiflash1.ld
ASFLAGS= -march=rv32i -mabi=ilp32 -mno-relax
LDFLAGS= -m elf32lriscv -nostdlib -norelax -T $(RVLINKSCRIPT)

# We need libgcc.a for `__mulsi3` multiplication used by mandelbrot.S
LIBGCC_PATH=$(TOOLCHAINDIR)/lib/gcc/riscv64-unknown-elf/8.3.0/rv32i/ilp32/libgcc.a

# Define our objects in one place for easy editing
OBJS = start_spiflash1.o wait.o putchar.o mandelbrot.o

all: firmware.bin

# Step-3: Convert the RISCV elf binary into a flat binary:
# (strip ELF headers and metadata, leave only "raw" machine code)
# ---------------------------------------------------------------
firmware.bin: mandel.spiflash.elf
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-objcopy $< $@ -O binary

# Step-2: Link the object files into a RISCV elf binary
# -----------------------------------------------------
mandel.spiflash.elf: $(OBJS)
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-ld $(OBJS) $(LDFLAGS) $(LIBGCC_PATH) -o $@

# Step-1: build object files (.o) from assembler source files (.S) 
# ----------------------------------------------------------------
%.o: %.S
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-as $(ASFLAGS) $< -o $@

clean:
	rm -f *.o *.bin *.elf

.SECONDARY:
.PHONY: all clean
