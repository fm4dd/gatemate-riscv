### Local Makefile, adding the exercise-specific code modules.  ###
### Anything else is defined in the upper directory centralized ###
### Makefile config.mk                                          ###
### ----------------------------------------------------------- ###
include ../config.mk
ADD_SRC += ../rtl-shared/clockworks.v \
           ../rtl-shared/pll_gatemate.v

# Setting local folder constraints file as workaround for p_r issue
# in https://github.com/fm4dd/gatemate-riscv/issues/1
PIN_DEF = gatemate-e1.ccf
