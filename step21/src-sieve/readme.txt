This assembly source code continuously prints the prime numbers 1..31
to the UART line, connected to the USB port. Needs a terminal program
to see the FPGA output.

 1st prime: 2
 2nd prime: 3
 3rd prime: 5
 4th prime: 7
 5th prime: 11
 6th prime: 13
 7th prime: 17
 8th prime: 19
 9th prime: 23
10th prime: 29
11th prime: 31
12th prime: 37
13th prime: 41
14th prime: 43
15th prime: 47
16th prime: 53
17th prime: 59
18th prime: 61
19th prime: 67
20th prime: 71
21st prime: 73
22nd prime: 79
23rd prime: 83
24th prime: 89
25th prime: 97
26th prime: 101
27th prime: 103
28th prime: 107
29th prime: 109
30th prime: 113
31st prime: 127
checksum:
   1772A48F OK

e.g.
miniterm --dtr=0 /dev/ttyUSB1 1000000

# PICOCOM exit: <ctrl> a <ctrl> x   package: sudo apt-get install picocom
picocom -b 1000000 /dev/ttyUSB1 --imap lfcrlf,crcrlf --omap delbs,crlf --send-cmd "ascii-xfr -s -l 30 -n"

