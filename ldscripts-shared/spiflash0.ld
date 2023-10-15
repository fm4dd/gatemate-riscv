MEMORY {
   FLASH (RX)  : ORIGIN = 0x00880000, LENGTH = 0x080000 /* 1M in flash */
}
SECTIONS {
    everything : {
	. = ALIGN(4);
	start.o (.text)
        *(.*)
    } >FLASH
}
