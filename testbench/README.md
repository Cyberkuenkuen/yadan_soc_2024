To check or change the test program for the simulation, see the file . /inst_to_test/Makefile, at line 26.

The test program is from https://github.com/riscv-software-src/riscv-tests/tree/master/isa

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

