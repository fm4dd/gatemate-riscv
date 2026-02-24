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
