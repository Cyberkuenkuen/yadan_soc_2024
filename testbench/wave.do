onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /yadan_riscv_sopc_tb/u_yadan_riscv_sopc/u_yadan_riscv/u_if_id/pc_i
add wave -noupdate /yadan_riscv_sopc_tb/u_yadan_riscv_sopc/u_yadan_riscv/u_if_id/inst_i
add wave -noupdate /yadan_riscv_sopc_tb/u_yadan_riscv_sopc/u_yadan_riscv/u_ctrl/stallreq_from_if
add wave -noupdate /yadan_riscv_sopc_tb/u_yadan_riscv_sopc/u_yadan_riscv/u_ctrl/stallreq_from_id
add wave -noupdate /yadan_riscv_sopc_tb/u_yadan_riscv_sopc/u_yadan_riscv/u_ctrl/stallreq_from_ex
add wave -noupdate /yadan_riscv_sopc_tb/u_yadan_riscv_sopc/u_yadan_riscv/u_ctrl/stallreq_from_mem
add wave -noupdate /yadan_riscv_sopc_tb/u_yadan_riscv_sopc/u_yadan_riscv/u_ctrl/branch_flag_i
add wave -noupdate /yadan_riscv_sopc_tb/u_yadan_riscv_sopc/u_yadan_riscv/u_ctrl/branch_addr_i
add wave -noupdate /yadan_riscv_sopc_tb/u_yadan_riscv_sopc/u_yadan_riscv/u_ctrl/stalled_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30297996 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 486
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {30108955 ps} {30519115 ps}
