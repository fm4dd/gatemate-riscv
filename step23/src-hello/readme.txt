In step 23, we use the spiflash0.ld linker script in our Makefile to declare
a 1MB risc-v storage area inside the flash. The storage area is allocated at
an offset of 0x80000 (512K) so it can co-exist with the FPGA bitsream below.

The spiflash0.ld script is inside the ../ldscripts-shared folder, containing:

MEMORY {
   FLASH (RX)  : ORIGIN = 0x00880000, LENGTH = 0x100000 /* 1 MB in flash */
}
SECTIONS {
    everything : {
	. = ALIGN(4);
	start.o (.text)
        *(.*)
    } >FLASH
}

The hello.S assembly source code continuously prints a "Hello World!"
message string to the UART line, connected to the PC USB port.