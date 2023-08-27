This C source code requires gcc compilation with -O2 to fit into the 6K RAM.
Without -O2, the program is 719 bytes too big, and we get following error:

riscv64-unknown-elf-ld: ST_NICCC.bram.elf section `everything' will not fit in region `BRAM'
riscv64-unknown-elf-ld: region `BRAM' overflowed by 715 bytes

The program creates a pseudo 3D animation data stream to the UART line,
 connected to the USB port. Needs a terminal program to see the FPGA output.

In my case the output was too slow, and only colored areas moved in no
coherent fashion that produced no recognizable image but showed something is working.
e.g.
miniterm --dtr=0 /dev/ttyUSB1 1000000

# PICOCOM exit: <ctrl> a <ctrl> x   package: sudo apt-get install picocom
picocom -b 1000000 /dev/ttyUSB1 --imap lfcrlf,crcrlf --omap delbs,crlf --send-cmd "ascii-xfr -s -l 30 -n"

