#Set the source directory

set TB_FILE ./yadan_riscv_sopc_tb.v
set RTL_DIR ../RTL
# set CORE_DIR ${RTL_DIR}/core
# set PERIPHERY_DIR ${RTL_DIR}/periphery
# set MEMORY_DIR ${RTL_DIR}/ram
# set SOC_DIR ${RTL_DIR}/soc

vlib work

# set hierarchy_files [split [read [open ${SOURCE_DIR}/hierarchy_vhdl.txt r]] "\n"]
# foreach filename [lrange ${hierarchy_files} 0 end-1] {
# 	vcom -2008 -work work ${SOURCE_DIR}/${filename}
# }

#Compile RTL design into "work"
set hierarchy_files [split [read [open ./questasim/hierarchy.txt r]] "\n"]
foreach filename [lrange ${hierarchy_files} 0 end-1] {
    vlog -work work ${RTL_DIR}/${filename}
}

#Compile testbench
vlog -work work ${TB_FILE}

#Open the simulation
vsim work.yadan_riscv_sopc_tb -voptargs=+acc

#Load the waveform.
# do wave.do

#Run simulation
run 1000000 ns
