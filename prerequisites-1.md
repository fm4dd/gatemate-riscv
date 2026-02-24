## Prerequisites 1

My development environment is a Linux virtual machine, running Debian 13 "Trixie".
I am using modest specs with 40GB disk and 8GB RAM.

### GateMate E1 development board

This tutorial is adopted for the Gatemate E1 development board from Cologne Chip. It is available from major distributors incl. Digikey with part-# [4158-CCGM1A1-E1-31B-ND](https://www.digikey.com/en/products/detail/cologne-chip/CCGM1A1-E1-31B/16087880).

### OSS CAD Suite Toolchain
The old GateMate-provided toolchain with the proprietary place-and-route tool from Cologne Chip has been superseeded when Gatemate FPGA support was added to nextpnr version 0.9 (release notes) on September 9, 2025. Now we get a unified toolchain experience with all tools being part of the open-source OSS CAD Suite.

Further information:
- GateMate Toolchain [Download] (https://colognechip.com/programmable-logic/gatemate/toolchain/)
- GateMate Toolchain [Quickstart] (https://colognechip.com/programmable-logic/gatemate/gatemate-toolchain-quickstart/)

Getting the toolchain package:

```
$ wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-02-19/oss-cad-suite-linux-x64-20260219.tgz
--2026-02-19 15:49:27--  https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-02-19/oss-cad-suite-linux-x64-20260219.tgz
Resolving github.com (github.com)... 20.27.177.113
Connecting to github.com (github.com)|20.27.177.113|:443... connected.
...
Connecting to release-assets.githubusercontent.com (release-assets.githubusercontent.com)|185.199.110.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 705282112 (673M) [application/octet-stream]
Saving to: ‘oss-cad-suite-linux-x64-20260219.tgz’

2026-02-19 15:50:33 (10.2 MB/s) - ‘oss-cad-suite-linux-x64-20260219.tgz’ saved [705282112/705282112]
```

Extract and check:

```
fm@nuc7fpga:~$ tar xfz oss-cad-suite-linux-x64-20260219.tgz 
fm@nuc7fpga:~$ ls -l oss-cad-suite
total 64
drwxr-xr-x  2 fm fm  4096 Feb 19 12:48 bin
-rw-r--r--  1 fm fm  2646 Feb 19 12:47 environment
-rw-r--r--  1 fm fm  1838 Feb 19 12:47 environment.fish
drwxr-xr-x  3 fm fm  4096 Dec 11  2024 etc
drwxr-xr-x 15 fm fm  4096 Feb 19 12:41 examples
drwxr-xr-x  4 fm fm  4096 Feb 19 12:47 include
drwxr-xr-x 13 fm fm 12288 Feb 19 12:48 lib
drwxr-xr-x  2 fm fm  4096 Feb 19 12:48 libexec
drwxr-xr-x  2 fm fm  4096 Nov 17  2024 license
drwxr-xr-x  2 fm fm  4096 Feb 19 12:48 py3bin
-rw-r--r--  1 fm fm  1399 Feb 19 12:47 README
drwxr-xr-x 19 fm fm  4096 Feb 19 12:46 share
drwxr-xr-x  4 fm fm  4096 Nov 17  2024 super_prove
-rw-r--r--  1 fm fm     8 Feb 19 12:46 VERSION
```

In addtion to the synthesis framework, place-and-route and bitstream programmer tools, the OSS CAD Suite also includes the range of simulation tools including iverilog, verilator and gtkwave.

### Set the toolchain path in config.mk

The path to the toolchain binaries can be configured in a single location inside the global Makefile [config.mk](https://github.com/fm4dd/gatemate-riscv/blob/main/config.mk). This Makefile is included in each step folders local Makefile. The local Makefile only sets the additional module files required for each step.

```
### config.mk
### ------------------------------------------------------------ ###
### Gatemate Makefile for oss-cad-suite toolchain (2026-02-11)   ###
###                                                              ###
### Central Makefile with shared settings across step01...19 The ###
### Steps only differ by using additional code modules that are  ###
### added into each step folders Makefile.                       ###
### ------------------------------------------------------------ ###

## toolchain location
YOSYS = /home/fm/oss-cad-suite/bin/yosys
PR    = /home/fm/oss-cad-suite/bin/nextpnr-himbaechel
PACK  = /home/fm/oss-cad-suite/bin/gmpack
OFL   = /home/fm/oss-cad-suite/bin/openFPGALoader
VLTR  = /home/fm/oss-cad-suite/bin/verilator
GTKW  = /home/fm/oss-cad-suite/bin/gtkwave
IVL   = /home/fm/oss-cad-suite/bin/iverilog
VVP   = /home/fm/oss-cad-suite/bin/vvp
IVLFLAGS = -Winfloop -g2012 -gspecify -Ttyp -DSIMULATION

## simulation libraries (oss-cad-suite: cpelib.v is now cells_sim.v)
CELLS_SYNTH = /home/fm/oss-cad-suite/share/yosys/gatemate/cells_sim.v

```
