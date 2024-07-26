## Generate .data file
Before running the testbench, please generate the .data file. 

In the current directory (testbench):

```
make clean -C ./inst_to_test
make all -C ./inst_to_test
```

To change the test program for the simulation, check the file ./inst_to_test/Makefile, at line 25.

```
SELECTED_S_FILE := $(rv32ui)add.S
```

## Run the testbench in Icarus Verilog

#### Single instruction test

In the current directory (testbench):

```
python ./iverilog/compile_rtl.py
vvp yadan_riscv_sopc_tb.vvp
```

If the test is successful, the program will print “test pass”.

To view the waveform:

```
gtkwave yadan_riscv_sopc_tb.vcd
```

#### Batch simulation

You can also test all instructions at once by running the batch simulation.

In the current directory (testbench):

```
python ./iverilog/test.py
```

After running, check the failed tests here: ./tempfile_sim/fail_list_ive.txt

## Run the testbench in Qestasim

Before running the testbench, please generate the .data file. 

#### Single instruction test

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

#### Batch simulation

In the current directory (testbench):

```
python ./questasim/testque.py
```

 After running, check the failed tests here: ./tempfile_sim/fail_list_que.txt

 ## Clearing temporary files

The simulation generates a series of temporary files:

  ./tempfile_simsim_list, ./tempfile_sim/last_index, ./work/... etc.

To delete them:

```
python clean.py
```
