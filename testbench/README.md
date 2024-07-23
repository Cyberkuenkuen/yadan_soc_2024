To check or change the test program for the simulation, see the file . /inst_to_test/Makefile, at line 26.

```
testfile += $(rv32ui)add.S
```

### Run the testbench in Icarus Verilog

In the current directory (testbench):

```
make clean -C ./inst_to_test
make all -C ./inst_to_test
python ./iverilog/compile_rtl.py
vvp yadan_riscv_sopc_tb.vvp
```

If the test is successful, the program will print “test pass”.

To view the waveform:

```
gtkwave yadan_riscv_sopc_tb.vcd
```

If you want to batch simulation or find out the instructions that are failing to simulate, you can make the following changes  . /inst_to_test/Makefile, from line 24.

```
SELECTED_S_FILE := $(rv32ui)add.S

ifeq ($(MAKECMDGOALS), all)
    SELECTED_S_FILE := $(shell python ..\iverilog\select_s_file.py)
endif

testfile+=start.S
testfile += $(SELECTED_S_FILE)
testfile += $(rv32ui)riscv_test.h 
testfile += $(rv32ui)test_macros.h
```
In the current directory (testbench):

```
python ./iverilog/test.py
```

### Run the testbench in Qestasim

In the current directory (testbench):

```
vsim -64 -do ./questasim/simulation.tcl
```

or

```
vsim -64
QuestaSim> -do ./questasim/simulation.tcl
```

If the test is successful, the program will print “test pass”.
