import sys
import subprocess
import os
import shutil

clean_dirs = {
r"./work",
r"./tempfile_sim"
}

clean_files = {
r"./yadan_riscv_sopc_tb.vcd",
r"./yadan_riscv_sopc_tb.vvp",
r"./transcript"
}

def main():

    # make clean
    make_clean_cmd = 'make clean -C ./inst_to_test'
    make_clean_process = subprocess.run(make_clean_cmd, stdout=subprocess.DEVNULL, shell=True)#运行make clean
    if make_clean_process.returncode != 0:
        print('!!!Fail, make clean command failed!!!')
    for file in clean_files :
        if(os.path.exists(file)):
            os.remove(file) 
    for dir in clean_dirs :
        if(os.path.exists(dir)):
            shutil.rmtree(dir) 
    print('清空完成')
    return 0

if __name__ == '__main__':
    sys.exit(main())

