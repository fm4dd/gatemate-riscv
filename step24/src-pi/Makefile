### ----------------------------------------------------------- ###
### Local Makefile for building the RISC-V native application.  ###
### Requires riscv-toolchain, linker script and elf-objcopy     ###
### bin conversion program. Creates the 'firmware.bin' output   ###
### for separate Flash upload before programming the FPGA.      ###
### ----------------------------------------------------------- ###
TOOLCHAINDIR=/home/fm/fpga/projects/git/gatemate-riscv/riscv-toolchain
RVLINKSCRIPT=/home/fm/fpga/projects/git/gatemate-riscv/ldscripts-shared/spiflash2.ld
ASFLAGS= -march=rv32i -mabi=ilp32 -mno-relax
LDFLAGS= -m elf32lriscv -nostdlib -norelax -T $(RVLINKSCRIPT)
CFLAGS= -march=rv32i -mabi=ilp32 -fno-pic -fno-stack-protector -w -Wl,--no-relax

# We need libgcc.a for various math operations (muldf3, divdf3, ...)
LIBGCC_PATH=$(TOOLCHAINDIR)/lib/gcc/riscv64-unknown-elf/8.3.0/rv32i/ilp32/libgcc.a
# We need libm for floating point math
LIBM_PATH=$(TOOLCHAINDIR)/riscv64-unknown-elf/lib/rv32i/ilp32/libm.a
# We need libc for log
LIBC_PATH=$(TOOLCHAINDIR)/riscv64-unknown-elf/lib/rv32i/ilp32/libc.a

# Combine the dependent libs into a single variable
# Note the order of the libs is critical!
DEPS_PATH = $(LIBM_PATH) $(LIBC_PATH) $(LIBGCC_PATH)

# Define our objects in one place for easy editing
OBJS = start_spiflash1.o wait.o print.o putchar.o pi.o

all: firmware.bin

# Step-3: Convert the RISCV elf binary into a flat binary:
# (strip ELF headers and metadata, leave only "raw" machine code)
# ---------------------------------------------------------------
firmware.bin: pi.spiflash.elf
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-objcopy $< $@ -O binary

# Step-2: Link the object files into a RISCV elf binary
# -----------------------------------------------------
pi.spiflash.elf: $(OBJS)
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-ld $(OBJS) $(LDFLAGS) $(DEPS_PATH) -o $@

# Step-1: build object files (.o) from assembler and C source files
# -----------------------------------------------------------------
%.o: %.S
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-as $(ASFLAGS) $< -o $@

%.o: %.c
	$(TOOLCHAINDIR)/bin/riscv64-unknown-elf-gcc $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o *.bin *.elf

.SECONDARY:
.PHONY: all clean
