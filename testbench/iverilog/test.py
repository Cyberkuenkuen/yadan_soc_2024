import sys
import subprocess
import os

##sim_list 是所有指令列表，运行后可以将错误分类
##fail_list 是上次报错后所有错误的指令列表


sim_file = './iverilog/sim_list.txt' 
#sim_file = '.\iverilog\fail_list.txt'


##所有错误类型
errors = {
    "make_clean_errors": [],
    "make_all_errors": [],
    "compile_rtl_errors": [],
    "vvp_errors": [],
    "timeout_errors": [],
    "fali_sim":[],
    "long_stay":[]
}

##读取仿真列表中的每一行的名称
def read_line_from_file(file_path, line_index):
    try:
        with open(file_path, 'r') as f:
            lines = f.readlines()
            # 确保索引在有效范围内
            if line_index < 0 or line_index >= len(lines):
                return f"索引 {line_index} 超出范围。文件共有 {len(lines)} 行。"
            return lines[line_index].strip()  # 使用strip()去除换行符，返回该行对应的文件名称
    except Exception as e:
        return f"读取文件名发生错误: {e}"


def read_last_index(filename):
    try:
        with open(filename, 'r') as f:
            return int(f.read().strip())##记录当前行数
    except FileNotFoundError:
        return -1

##写当前行数，用于初始化
def write_last_index(filename, index):
    with open(filename, 'w') as f:
        f.write(str(index))


def main():
    file_path = sim_file  # 要读取的文件（sim_list或者fail_list）
    with open(file_path, 'r') as f:
            lines = f.readlines()
    index_file = os.path.join('./iverilog/last_index.txt')#存放当前行数的文件
    write_last_index(index_file, 0)#初始化
    last_index = read_last_index(index_file)#读行数
    current_s_file = read_line_from_file(file_path, last_index)#当前行数对应的 指令名称.S

    
    for i in range(len(lines)):

        # make clean
        print("---------------------------------------------------------check---------------------------------------------------------")
        make_clean_cmd = 'make clean -C ./inst_to_test'
        make_clean_process = subprocess.run(make_clean_cmd, shell=True)#运行make clean
        if make_clean_process.returncode != 0:
            print('!!!Fail, make clean command failed!!!')
            errors['make_clean_errors'].append(current_s_file)
            continue
            

        # make all
        make_all_cmd = 'make all -C ./inst_to_test'
        make_all_process = subprocess.run(make_all_cmd, shell=True)#
        last_index = read_last_index(index_file)-1
        current_s_file = read_line_from_file(file_path, last_index)# 读当前行数对应的指令
        if current_s_file:
            print(f'\n****************{current_s_file}**************** \n')
      
        if make_all_process.returncode != 0:
            print('!!!Fail, make all command failed!!!')
            errors['make_all_errors'].append(current_s_file)
            continue

        # Compile RTL files
        compile_cmd = 'python ./iverilog/compile_rtl.py'
        compile_process = subprocess.run(compile_cmd, shell=True)
        if compile_process.returncode != 0:
            print('!!!Fail, compile_rtl command failed!!!')
            errors['compile_rtl_errors'].append(current_s_file)
            continue

        # vvp
        vvp_cmd = ['vvp', 'yadan_riscv_sopc_tb.vvp']
        try:
            process = subprocess.run(vvp_cmd, timeout=2, stdout=subprocess.PIPE ,text=True)
            output = process.stdout# 读vvp后的输出

            if process.returncode != 0:
                print('!!!Fail, vvp command failed!!!')
                errors['vvp_errors'].append(current_s_file)
                continue
            key = output.splitlines(False)# 将输出拆分为不带换行的字符串组
            print(key)# key[4]对应的是输出的pass和fail以及time信息，这里为了方便改了点.v文件
            if(key[4] == 'pass'):
                print('pass!!')
            elif(key[4] == 'fail'):
                print('fail!!!')
                errors['fali_sim'].append(current_s_file)
            elif(key[4] == 'time'):
                print('sim-timeout')
                errors['timeout_errors'].append(current_s_file)
            print(output)

        except subprocess.TimeoutExpired:# 卡着不动的情况
            print('!!!Fail, vvp exec timeout!!!')
            errors['long_stay'].append(current_s_file)
            continue

    print('compile_rtl_errors:',errors['compile_rtl_errors'])
    print('make_all_errors',errors['make_all_errors'])
    print('make_clean_errors',errors['make_clean_errors'])
    print('timeout_errors',errors['timeout_errors'])
    print('vvp_errors',errors['vvp_errors'])
    print('long_stay:',errors['long_stay'])
    print('fail_sim:',errors['fali_sim'])
    fail_file_path = "./iverilog/fail_list.txt"    # 替换为你的输出文件路径
    ##这里只存了long_stay的错误，可以改
    with open(fail_file_path,'a') as f:
        for filename in errors['long_stay']:
            f.write(f"{filename}\n")
        print(f"错误文件已经全部导入")


    return 0

if __name__ == '__main__':
    sys.exit(main())

