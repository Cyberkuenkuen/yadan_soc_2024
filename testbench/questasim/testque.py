import sys
import subprocess
import os

##sim_list 是所有指令列表，运行后可以将错误分类
##fail_list 是上次报错后所有错误的指令列表


sim_file = './tempfile_sim/sim_list.txt' 
#sim_file = './tempfile_sim/fail_list_que.txt'


##所有错误类型
errors = {
    "make_clean_errors": [],
    "make_errors": [],
    "compile_rtl_errors": [],
    "vsim_errors": [],
    "timeout_errors": [],
    "fail_sim":[],
    "long_stay":[]
}

def write_s_files_to_file(directory, output_file):
    try:
        # 指定要提取的特定目录
        target_dirs = ['rv32ui', 'rv32um']
        s_files = []
        
        # 遍历指定的目录
        for target_dir in target_dirs:
            target_path = os.path.join(directory, target_dir)
            
            # 检查目录是否存在
            if os.path.isdir(target_path):
                # 获取目录中的所有文件
                files_in_dir = os.listdir(target_path)
                
                # 过滤出以 .S 结尾的文件并添加路径
                s_files += [f'./{target_dir}/{filename}' for filename in files_in_dir if filename.endswith('.S')]
        
        # 将文件名写入到输出文件中
        with open(output_file, 'w') as f:
            for filename in s_files:
                f.write(f"{filename}\n")
                
        print(f"所有文件名已写入 {output_file}")
        
    except Exception as e:
        print(f"发生错误: {e}")
        
    except Exception as e:
        print(f"发生错误: {e}")

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
    ##新建一个存放临时文件的目录
    os.makedirs(r'./tempfile_sim', exist_ok=True)
    ##将要仿真的.S文件写进sim_list.txt文件

    directory_path = r"./inst_to_test"  # 替换为你的目录路径
    output_file_path = r"./tempfile_sim/sim_list.txt"    # 替换为你的输出文件路径
    write_s_files_to_file(directory_path, output_file_path)


    file_path = sim_file  # 要读取的文件（sim_list或者fail_list）
    with open(file_path, 'r') as f:
            lines = f.readlines()
    index_file = os.path.join(r'./tempfile_sim/last_index.txt')#存放当前行数的文件
    write_last_index(index_file, 0)#初始化
    last_index = read_last_index(index_file)#读行数
    current_s_file = read_line_from_file(file_path, last_index)#当前行数对应的 指令名称.S
    vsim_cmd = 'vsim -c -64 -do ./questasim/compile.tcl'
    subprocess.run(vsim_cmd, stdout=subprocess.PIPE, input='exit\n', text=True)

    for i in range(len(lines)):

        # make clean
        make_clean_cmd = 'make clean -C ./inst_to_test'
        make_clean_process = subprocess.run(make_clean_cmd, stdout=subprocess.DEVNULL, shell=True)#运行make clean
        if make_clean_process.returncode != 0:
            print('!!!Fail, make clean command failed!!!')
            errors['make_clean_errors'].append(current_s_file)
            continue
            

        # make batch_sim
        make_cmd = 'make batch_sim -C ./inst_to_test'
        make_process = subprocess.run(make_cmd, stdout=subprocess.DEVNULL, shell=True)#
        last_index = read_last_index(index_file)-1
        current_s_file = read_line_from_file(file_path, last_index)# 读当前行数对应的指令
        if current_s_file:
            print(f'\n****************{current_s_file}**************** \n')
      
        if make_process.returncode != 0:
            print('!!!Fail, make command failed!!!')
            errors['make_errors'].append(current_s_file)
            continue

        # # Compile RTL files
        # compile_cmd = 'vsim -c -64 -do ./questasim/compile.tcl'
        # compile_process = subprocess.run(compile_cmd, shell=True)
        # if compile_process.returncode != 0:
        #     print('!!!Fail, vsim command failed!!!')
        #     errors['compile_rtl_errors'].append(current_s_file)
        #     continue

        # vsim
        vsim_cmd = 'vsim -c -64 -do ./questasim/run_sim.tcl'
        try:
            process = subprocess.run(vsim_cmd, timeout=10, stdout=subprocess.PIPE ,text=True)
            output = process.stdout# 读vsim后的输出

            if process.returncode != 0:
                print('!!!Fail, vsim command failed!!!')
                errors['vsim_errors'].append(current_s_file)
                continue
            key = output.splitlines(False)# 将输出拆分为不带换行的字符串组
            # print(output)# key[4]对应的是输出的pass和fail以及time信息，这里为了方便改了点testbench.v文件
            if '# pass' in key:
                print('pass!!')
            elif '# fail' in key:
                print('fail!!!')
                errors['fail_sim'].append(current_s_file)
            elif '# time' in key:
                print('sim-timeout')
                errors['timeout_errors'].append(current_s_file)
            else: 
                print('nothing')

        except subprocess.TimeoutExpired:# 卡着不动的情况
            print('!!!Fail, vsim exec timeout!!!')
            errors['long_stay'].append(current_s_file)
            continue

    print('compile_rtl_errors:',errors['compile_rtl_errors'])
    print('make_clean_errors',errors['make_clean_errors'])
    print('make_errors',errors['make_errors'])
    print('vsim_errors',errors['vsim_errors'])
    print('long_stay:',errors['long_stay'])
    print('timeout_errors',errors['timeout_errors'])
    print('fail_sim:',errors['fail_sim'])

    fail_file_path = r"./tempfile_sim/fail_list_que.txt"    # 输出文件路径
    with open(fail_file_path,'w') as f:
        f.write('********** Compile failed: **********\n')
        for filename in errors['make_errors']:
            f.write(f"{filename}\n")


        f.write('********** Long stay: **********\n')
        for filename in errors['long_stay']:
            f.write(f"{filename}\n")

        f.write('********** Timeout: **********\n')
        for filename in errors['timeout_errors']:
            f.write(f"{filename}\n")
        
        f.write('********** Simulation failed: **********\n')
        for filename in errors['fail_sim']:
            f.write(f"{filename}\n")

        print(f"Check the failed tests here: ./tempfile_sim/fail_list_que.txt")

    return 0

if __name__ == '__main__':
    sys.exit(main())

