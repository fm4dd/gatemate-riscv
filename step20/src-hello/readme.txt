This assembly source code continuously prints the string "Hello, world !"
to the UART line, connected to the USB port. Needs a terminal program
to see the FPGA output.

Hello, world !
Hello, world !
Hello, world !
Hello, world !
Hello, world !

e.g.
miniterm --dtr=0 /dev/ttyUSB1 1000000

# PICOCOM exit: <ctrl> a <ctrl> x   package: sudo apt-get install picocom
picocom -b 1000000 /dev/ttyUSB1 --imap lfcrlf,crcrlf --omap delbs,crlf --send-cmd "ascii-xfr -s -l 30 -n"

