## Prerequisites 1

My development environment is a Linux virtual machine, running Debian 12 "Bookworm".

### GateMate E1 development board

This tutorial is adopted for the Gatemate E1 development board from Cologne Chip. It is available from major distributors incl. Digikey with part-# [4158-CCGM1A1-E1-31B-ND](https://www.digikey.com/en/products/detail/cologne-chip/CCGM1A1-E1-31B/16087880).

### Cologne Chip toolchain

The latest cc-toolchain-linux.tar.gz package can be downloaded from the Cologne Chip website. Access to the download requries prior user registration. After download, extract the package which contains the pre-compiled toolchain, together with two demo apps and latest data sheets.

```
$ tar xvfz cc-toolchain-linux.tar.gz
```

Now we can check:

```
$ ls -l cc-toolchain-linux/bin/*
-rw-r--r-- 1 fm fm   87 Jul 20 20:29 cc-toolchain-linux/bin/VERSION

cc-toolchain-linux/bin/openFPGALoader:
total 5276
-rw-r--r-- 1 fm fm   11357 Oct  7  2022 LICENSE
-rwxr-xr-x 1 fm fm 5387056 Mar  2 21:18 openFPGALoader

cc-toolchain-linux/bin/p_r:
total 17072
-rw-r--r-- 1 fm fm   487860 Jun 30 22:34 cc_best_eco_dly.dly
-rw-r--r-- 1 fm fm   502011 Jun 30 22:34 cc_best_lpr_dly.dly
-rw-r--r-- 1 fm fm   482094 Jun 30 22:34 cc_best_spd_dly.dly
-rw-r--r-- 1 fm fm   525161 Jun 30 22:34 cc_typ_eco_dly.dly
-rw-r--r-- 1 fm fm   551963 Jun 30 22:34 cc_typ_lpr_dly.dly
-rw-r--r-- 1 fm fm   505100 Jun 30 22:34 cc_typ_spd_dly.dly
-rw-r--r-- 1 fm fm   508566 Jun 30 22:34 cc_worst_eco_dly.dly
-rw-r--r-- 1 fm fm   613485 Jun 30 22:34 cc_worst_lpr_dly.dly
-rw-r--r-- 1 fm fm   563292 Jun 30 22:34 cc_worst_spd_dly.dly
-rwxr-xr-x 1 fm fm   250336 Jul 10 16:12 cpelib.v
-rwx--x--x 1 fm fm 12465488 Jul 20 20:23 p_r

cc-toolchain-linux/bin/yosys:
total 35464
-rw-r--r--  1 fm fm      777 May 17 15:48 COPYING
drwxr-xr-x 22 fm fm     4096 May 31 01:47 share
-rwxr-xr-x  1 fm fm 15262672 May 31 01:47 yosys
-rwxr-xr-x  1 fm fm 18146992 May 31 01:47 yosys-abc
-rwxr-xr-x  1 fm fm     3256 May 31 01:47 yosys-config
-rwxr-xr-x  1 fm fm  2815312 May 31 01:47 yosys-filterlib
-rwxr-xr-x  1 fm fm    69597 May 31 01:47 yosys-smtbmc
```

Cologne Chip website: https://www.colognechip.com/

### iVerilog simulation

iVerlog can be installed from Debian repositories:

```
$ sudo apt-get install iverilog
```

Now we can check:
```
$ iverilog -V
Icarus Verilog version 11.0 (stable) ()

Copyright 1998-2020 Stephen Williams
...
```

iVerilog website: https://steveicarus.github.io/iverilog/

### Verilator simulation

Verilator can be installed from Debian repositories:

```
$ sudo apt-get install verilator
```
Now we can check:
```
$ verilator -V
Verilator 5.006 2023-01-22 rev (Debian 5.006-3)

Copyright 2003-2023 by Wilson Snyder.  Verilator is free software; you can
redistribute it and/or modify the Verilator internals under the terms of
either the GNU Lesser General Public License Version 3 or the Perl Artistic
License Version 2.0.
...
```

A newer Verilator version 5.013 is available within the 'oss-cad-suite' package if needed.

Verilator website: https://www.veripool.org/verilator/

### Set the toolchain path in config.mk

The path to the toolchain binaries can be configured in a single location inside the global Makefile [config.mk](https://github.com/fm4dd/gatemate-riscv/blob/main/config.mk). This Makefile is included in each step folders local Makefile. The local Makefile only sets the additional module files required for each step.
