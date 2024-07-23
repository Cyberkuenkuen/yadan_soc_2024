import os
import sys



def read_line_from_file(file_path, line_index):
    try:
        with open(file_path, 'r') as f:
            lines = f.readlines()
            # 确保索引在有效范围内
            if line_index < 0 or line_index >= len(lines):
                return f"索引 {line_index} 超出范围。文件共有 {len(lines)} 行。"
            return lines[line_index].strip()  # 使用strip()去除换行符
    except Exception as e:
        return f"读取文件名发生错误: {e}"


def read_last_index(filename):
    try:
        with open(filename, 'r') as f:
            return int(f.read().strip())
    except FileNotFoundError:
        return -1

def write_last_index(filename, index):
    with open(filename, 'w') as f:
        f.write(str(index))

def main():
    
     index_file = os.path.join('..\iverilog\last_index.txt')
     last_index = read_last_index(index_file)
     next_index = (last_index + 1)
     write_last_index(index_file, next_index)
     file_path = '../iverilog/sim_list.txt'   # 要读取的文件
     line_index = last_index  # 要读取的行索引（例如，读取第3行内容，索引从0开始）
     line_content = read_line_from_file(file_path, line_index)
     print(line_content)

##用于将makefile文件中的要仿真的文件名替换掉
if __name__ == '__main__':
    main()
