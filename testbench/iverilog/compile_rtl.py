import sys
import filecmp
import subprocess
import sys
import os

def main():
    tb_file = r'yadan_riscv_sopc_tb.v'
    # rtl_dir = sys.argv[1]
    rtl_dir = r'../RTL'
    core_dir = rtl_dir + r'/core'
    periphery_dir = rtl_dir + r'/periphery'
    memory_dir = rtl_dir + r'/ram'
    soc_dir = rtl_dir + r'/soc'

    # iverilog程序
    iverilog_cmd = ['iverilog']
    # 顶层模块
    iverilog_cmd += ['-s', r'yadan_riscv_sopc_tb']
    # 编译生成文件
    iverilog_cmd += ['-o', r'yadan_riscv_sopc_tb.vvp']
    # 头文件(defines.v)路径
    iverilog_cmd += ['-I', core_dir]
    # 宏定义，仿真输出文件
    iverilog_cmd += ['-D', r'OUTPUT="yadan_riscv_sopc_tb.output"']

    # testbench
    iverilog_cmd.append(tb_file)

    # core
    iverilog_cmd.append(core_dir + r'/yadan_defs.v')
    iverilog_cmd.append(core_dir + r'/yadan_riscv.v')
    iverilog_cmd.append(core_dir + r'/pc_reg.v')
    iverilog_cmd.append(core_dir + r'/regsfile.v')
    iverilog_cmd.append(core_dir + r'/if_id.v')
    iverilog_cmd.append(core_dir + r'/id.v')
    iverilog_cmd.append(core_dir + r'/id_ex.v')
    iverilog_cmd.append(core_dir + r'/ex.v')
    iverilog_cmd.append(core_dir + r'/muldiv/absolute_value.v')
    iverilog_cmd.append(core_dir + r'/muldiv/long_slow_div_denom_reg.v')
    iverilog_cmd.append(core_dir + r'/muldiv/mul_div_32.v')
    iverilog_cmd.append(core_dir + r'/ex_mem.v')
    iverilog_cmd.append(core_dir + r'/mem.v')
    iverilog_cmd.append(core_dir + r'/mem_wb.v')
    iverilog_cmd.append(core_dir + r'/ctrl.v')
    iverilog_cmd.append(core_dir + r'/csr_reg.v')
    iverilog_cmd.append(core_dir + r'/cpu_ahb_if.v')
    iverilog_cmd.append(core_dir + r'/cpu_ahb_mem.v')
    
    # periphery 没加完
    iverilog_cmd.append(periphery_dir + r'/amba_ahb_m2s5.v')

    # memory
    iverilog_cmd.append(memory_dir + r'/AHB2MEM_RAM.v')
    iverilog_cmd.append(memory_dir + r'/AHB2MEM_ROM.v')
    iverilog_cmd.append(memory_dir + r'/data_ram.v')
    iverilog_cmd.append(memory_dir + r'/inst_rom.v')

    # soc
    iverilog_cmd.append(soc_dir + r'/yadan_riscv_sopc.v')

    # 编译
    process = subprocess.Popen(iverilog_cmd)
    process.wait(timeout=10)

if __name__ == '__main__':
    sys.exit(main())