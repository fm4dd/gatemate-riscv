## Prerequisites 2

In order to run RISC-V application programs from standard 'C' or assembly source code, we need a RISC-V compiler toolchain, plus a hex file format conversion program for FPGA upload. Below is the setup I used. My development environment is a Linux virtual machine, running Debian 12 "Bookworm".


### RISC-V toolchain

For the RISC-V toolchain I used the same riscv64-unknown-elf-gcc package as in the original tutorial. There are newer versions out that I haven't tested. The download location is below:

https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14.tar.gz
(222M)

```
$ tar xvfz riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14.tar.gz
fm@nuc7fpga:~/fpga/projects/git$ tar xvfz riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14.tar.gz 
\riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/
riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/lib/
...
```
Now we can check:

```
$ cd riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/
$ ls -l bin
total 38444
-rwxrwxrwx 1 root root  892336 Apr  1  2020 riscv64-unknown-elf-addr2line
-rwxrwxrwx 1 root root  925856 Apr  1  2020 riscv64-unknown-elf-ar
-rwxrwxrwx 1 root root 1287552 Apr  1  2020 riscv64-unknown-elf-as
-rwxrwxrwx 1 root root 2513648 Apr  1  2020 riscv64-unknown-elf-c++
-rwxrwxrwx 1 root root  891128 Apr  1  2020 riscv64-unknown-elf-c++filt
-rwxrwxrwx 1 root root 2509504 Apr  1  2020 riscv64-unknown-elf-cpp
-rwxrwxrwx 1 root root   38552 Apr  1  2020 riscv64-unknown-elf-elfedit
-rwxrwxrwx 1 root root 2513648 Apr  1  2020 riscv64-unknown-elf-g++
-rwxrwxrwx 1 root root 2509456 Apr  1  2020 riscv64-unknown-elf-gcc
-rwxrwxrwx 1 root root 2509456 Apr  1  2020 riscv64-unknown-elf-gcc-8.3.0
...
```


### firmware_words

The firmware_words program is needed to generate the hexadecimal machine code file for use with Verilogs $readmemh() function. It is needed for generating the FPGA flash or memory file upload format in step20 through step24. The source code for the program can be found inside Bruno Levy's repository. We need these files:


wget https://raw.githubusercontent.com/BrunoLevy/learn-fpga/master/FemtoRV/FIRMWARE/TOOLS/FIRMWARE_WORDS_SRC/firmware_words.cpp  
wget https://raw.githubusercontent.com/BrunoLevy/learn-fpga/master/FemtoRV/FIRMWARE/LIBFEMTORV32/femto_elf.c  
wget https://raw.githubusercontent.com/BrunoLevy/learn-fpga/master/FemtoRV/FIRMWARE/LIBFEMTORV32/femto_elf.h  
wget https://raw.githubusercontent.com/BrunoLevy/learn-fpga/master/FemtoRV/FIRMWARE/LIBFEMTORV32/femtorv32.h  
wget https://raw.githubusercontent.com/BrunoLevy/learn-fpga/master/FemtoRV/FIRMWARE/LIBFEMTORV32/HardwareConfig_bits.h


Now we can build the binary with g++:

```
$ cd riscv-toolchain
$ mkdir firmware_words
$ cd firmware_words
```
...get the files with wget...
```
$ ls -l
total 29
-rwxrwxrwx 1 root root  5941 Aug 21 22:34 femto_elf.c
-rwxrwxrwx 1 root root  2145 Aug 21 22:34 femto_elf.h
-rwxrwxrwx 1 root root  5345 Aug 21 22:34 femtorv32.h
-rwxrwxrwx 1 root root 13371 Aug 21 22:34 firmware_words.cpp
-rwxrwxrwx 1 root root   603 Aug 21 22:34 HardwareConfig_bits.h

$ g++ -I. -DSTANDALONE_FEMTOELF firmware_words.cpp femto_elf.c -o firmware_words

$ ls -l firmware_words
-rwxrwxrwx 1 root root 53272 Aug 21 22:35 firmware_words
```
Now we can check:
```
$ ./firmware_words
usage: ./firmware_words input.rawhex|input.elf <-out out.hex|out.bin> <-from_addr addr> <-to_addr addr> <-ram ram_amount> <-max_addr max_address> <-verilog femtosoc.v>
  -out out.hex|out.bin         : VERILOG .hex for readmemh() or plain binary file
  -from_addr addr -to_addr addr: optional address sequence to be saved (default: save whole RAM)
  -ram ram_size                : specify RAM size explicity
  -verilog source.v            : get RAM size from verilog source (NRV_RAM=xxxx)
  -max_addr addr               : specify optional maximum address. For instance, can be used to make sure some space remains for the stack.
```


The firmware_words program code is Copyright (c) 2020-2021, Bruno Levy All rights reserved. ([License](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/LICENSE.md))
