ifndef CROSS_COMPILE
CROSS_COMPILE = riscv-none-embed-#riscv32-unknown-elf-
endif

RISCV_ARCH := rv32im
RISCV_ABI := ilp32

GCC = $(CROSS_COMPILE)gcc
AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

export CROSS_COMPILE

ASFLAGS = -march=$(RISCV_ARCH)

CFLAGS += -march=$(RISCV_ARCH)
CFLAGS += -mabi=$(RISCV_ABI)
CFLAGS += -O2 -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles --std=gnu99 
CFLAGS += -DSIMULATION

# rv32um = ./rv32um/
# rv32ui = ./rv32ui/

# SELECTED_S_FILE := $(rv32ui)add.S

# ifeq ($(MAKECMDGOALS), batch_sim)
#     SELECTED_S_FILE := $(shell python ../iverilog/select_s_file.py)
# endif

# testfile += start.S
# testfile += $(SELECTED_S_FILE)
# testfile += $(rv32ui)riscv_test.h 
# testfile += $(rv32ui)test_macros.h
testfile += start.S
testfile += trap_entry.S
testfile += init.c
testfile += main.c
testfile += trap_handler.c
testfile += utils.h
testfile += timer.h

# *************************************
# Rules of Compilation
# *************************************

all: inst_rom.data simple.dump

batch_sim: inst_rom.data

simple.elf:
	$(GCC) $(CFLAGS) $(testfile) -Tlink.ld -o $@  

simple.bin: simple.elf
	$(OBJCOPY) -O binary $< $@

lo.mif: simple.bin
	rom2mif simple.bin hi.mif mh.mif ml.mif lo.mif

simple.dump: simple.elf
	$(OBJDUMP) --disassemble-all $< > $@

simple.hex: simple.elf
	$(OBJCOPY) -O verilog $< $@

inst_rom.data: simple.bin
#	rom2mif $< hi.mif mh.mif ml.mif lo.mif
	hexdump -e '"%08x\n"' -v $< > $@

# sim: inst_rom.data
# 	# python split_data.py
# 	cp -rf *.data  ../../
# 	cd ../../;python al_mif.py 
# 	cd ../../;cp -rf *.mif ./output_files

# test: 
# 	cd ../../sim ; ./build.bat
	
	
clean:
	rm -f simple.elf simple.hex simple.bin  simple.dump *.mif *.data *.o




