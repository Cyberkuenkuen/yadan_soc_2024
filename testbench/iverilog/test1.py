import sys
import filecmp
import subprocess
import sys
import os

def main():
    #print(sys.argv[0] + ' ' + sys.argv[1] + ' ' + sys.argv[2])

    # 1.编译rtl文件
    cmd = r'python compile_rtl.py' + r'../RTL'
    f = os.popen(cmd)
    f.close()

    # 2.运行
    vvp_cmd = ['vvp']
    vvp_cmd.append(r'yadan_riscv_sopc_tb.vvp')
    process = subprocess.Popen(vvp_cmd)
    try:
        process.wait(timeout=10)
    except subprocess.TimeoutExpired:
        print('!!!Fail, vvp exec timeout!!!')

    # 3.查看波形
    

if __name__ == '__main__':
    sys.exit(main())