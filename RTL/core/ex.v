/******************************************************************************
MIT License

Copyright (c) 2020 BH6BAO

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

******************************************************************************/

`include "yadan_defs.v"

module ex(
    input   wire                int_assert_i,  // 中断发生标志
    input   wire[`InstAddrBus]  int_addr_i,    // 中断跳转地址

    // from id/ex
    input   wire[`InstAddrBus]  pc_i,
    input   wire[`InstBus]      inst_i,
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`AluSelBus]    alusel_i,
    input   wire[`RegBus]       operand1_i,
    input   wire[`RegBus]       operand2_i,
    input   wire                wreg_i,
    input   wire[`RegAddrBus]   wreg_addr_i,
    
    input   wire[`RegBus]       csr_data_i,
    input   wire                wcsr_i,
    input   wire[`DataAddrBus]  wcsr_addr_i,

    // from mul_div
    input   wire[`DoubleRegBus] muldiv_result_i,
    input   wire                muldiv_done_i,

    // to mul_div
    output  reg                 muldiv_start_o,
    output  reg[`RegBus]        muldiv_dividend_o,
    output  reg[`RegBus]        muldiv_divisor_o,
    output  reg                 mul_or_div_o,
    output  reg                 muldiv_reg1_sign_o,
    output  reg                 muldiv_reg2_sign_o,

    // to ex_mem
    output  wire                wreg_o,         //写寄存器使能
    output  wire[`RegAddrBus]   wreg_addr_o,    //写寄存器地址
    output  wire[`RegBus]       wreg_data_o,    //写寄存器数据

    output  reg[`AluOpBus]      aluop_o,
    output  reg[`DataAddrBus]   memaddr_o,
    output  reg[`RegBus]        operand2_o,

    // to csr_reg
    output  wire                wcsr_o,         // write csr enable
    output  wire[`DataAddrBus]  wcsr_addr_o,
    output  reg[`RegBus]        wcsr_data_o,   

    // branch info
    output  wire                branch_flag_o,
    output  wire[`RegBus]       branch_addr_o
);

    reg[`RegAddrBus]        wreg_addr;
    reg                     wreg;
    reg[`RegBus]            wreg_data;
    reg                     branch_flag;
    reg[`InstAddrBus]       branch_addr;
    
    // assign  wreg_o          = (int_assert_i == `INT_ASSERT) ? `WriteDisable: wreg;
    assign  wreg_o          = wreg;
    assign  wreg_addr_o     = wreg_addr;
    assign  wreg_data_o     = wreg_data;

    assign  branch_flag_o   = ((branch_flag == `BranchEnable) || (int_assert_i == `INT_ASSERT)) ? `BranchEnable : `BranchDisable;
    assign  branch_addr_o   = (int_assert_i == `INT_ASSERT) ? int_addr_i : branch_addr;


    // 保存运算结果
    reg[`RegBus]    logicout;
    reg[`RegBus]    compare;        // 比较结果
    reg[`RegBus]    shiftres;       // 移位结果
    reg[`RegBus]    arithresult;    // 算术结果
    reg[`RegBus]    branchres;      // 跳转回写偏移结果

    // aluop 传递到 访存阶段
    always @(*) begin
        aluop_o  = aluop_i;
        operand2_o   = operand2_i; 
        case (alusel_i)
            `EXE_RES_LOAD:  memaddr_o   = (operand1_i + {{20{inst_i[31]}}, inst_i[31:20]});
            `EXE_RES_STORE: memaddr_o   = (operand1_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]});
            default:        memaddr_o   = `ZeroWord;
        endcase
    end

    // 1. 根据 aluop_i 指示的运算子类型进行运算 
    //arith
    always @(*) begin
        if (muldiv_done_i) begin   // mul/div 运算结束
            muldiv_start_o          =  1'b0;
            mul_or_div_o            =  `MUL;
            muldiv_dividend_o       =  `ZeroWord;
            muldiv_divisor_o        =  `ZeroWord;
            muldiv_reg1_sign_o      = `Unsigned;
            muldiv_reg2_sign_o      = `Unsigned; 
            case (aluop_i)
                `EXE_DIV,`EXE_DIVU,`EXE_MULHU,`EXE_MULH,`EXE_MULHSU  : begin
                arithresult         =  muldiv_result_i[63:32]; 
                end 
                `EXE_REM,`EXE_REMU, `EXE_MUL : begin
                    arithresult     =  muldiv_result_i[31:0];
                end
                `EXE_ADD: begin
                    arithresult     = (operand1_i + operand2_i);
                end 
                `EXE_SUB: begin
                    arithresult     = (operand1_i - operand2_i);
                end      
                default: 
                    arithresult     = `ZeroWord;
            endcase
            
        end else begin     //mul/div 没有运行或没有运行结束
            arithresult             = `ZeroWord;
            muldiv_start_o          =  1'b0;
            mul_or_div_o            =  `MUL;
            muldiv_dividend_o       =  `ZeroWord;
            muldiv_divisor_o        =  `ZeroWord;
            muldiv_reg1_sign_o      = `Unsigned;
            muldiv_reg2_sign_o      = `Unsigned; 
            case (aluop_i)
                `EXE_DIV,`EXE_REM  : begin
                    muldiv_start_o      =  1'b1;
                    mul_or_div_o        =  `DIV;
                    muldiv_dividend_o   =  operand1_i;
                    muldiv_divisor_o    =  operand2_i;
                    muldiv_reg1_sign_o  = `Signed;
                    muldiv_reg2_sign_o  = `Signed;
                end
                `EXE_DIVU,`EXE_REMU : begin
                    muldiv_start_o      =  1'b1;
                    mul_or_div_o        =  `DIV;
                    muldiv_dividend_o   =  operand1_i;
                    muldiv_divisor_o    =  operand2_i;
                    muldiv_reg1_sign_o  = `Unsigned;
                    muldiv_reg2_sign_o  = `Unsigned;
                end
                `EXE_MUL,`EXE_MULHU  : begin
                    muldiv_start_o      =  1'b1;
                    mul_or_div_o        =  `MUL;
                    muldiv_dividend_o   =  operand1_i;
                    muldiv_divisor_o    =  operand2_i;
                    muldiv_reg1_sign_o  = `Unsigned;
                    muldiv_reg2_sign_o  = `Unsigned;
                end
                `EXE_MULH:  begin
                    muldiv_start_o      =  1'b1;
                    mul_or_div_o        =  `MUL;
                    muldiv_dividend_o   =  operand1_i;
                    muldiv_divisor_o    =  operand2_i;
                    muldiv_reg1_sign_o  = `Signed;
                    muldiv_reg2_sign_o  = `Signed;
                end
                `EXE_MULHSU: begin
                    muldiv_start_o      =  1'b1;
                    mul_or_div_o        =  `MUL;
                    muldiv_dividend_o   =  operand1_i;
                    muldiv_divisor_o    =  operand2_i;
                    muldiv_reg1_sign_o  = `Signed;
                    muldiv_reg2_sign_o  = `Unsigned;
                end
                `EXE_ADD: begin
                    arithresult         = operand1_i + operand2_i;
                end 
                `EXE_SUB: begin
                    arithresult         = operand1_i - operand2_i;
                end
                default: begin
                    muldiv_start_o      =  1'b0;
                    mul_or_div_o        =  `MUL;
                    muldiv_dividend_o   =  `ZeroWord;
                    muldiv_divisor_o    =  `ZeroWord;
                    muldiv_reg1_sign_o  = `Unsigned;
                    muldiv_reg2_sign_o  = `Unsigned; 
                    arithresult         = `ZeroWord;
                end
            endcase
        end
    end
    
    // logic 
    always @ (*) begin
        case (aluop_i)
            `EXE_AND:   logicout = (operand1_i & operand2_i);
            `EXE_OR:    logicout = (operand1_i | operand2_i);
            `EXE_XOR:   logicout = (operand1_i ^ operand2_i);
            default:    logicout = `ZeroWord;
        endcase
    end // always

    // compare
    always @(*) begin
        case (aluop_i)
            `EXE_SLT:  begin
                if (operand1_i[31] != operand2_i[31]) begin             // 有符号数，首先比较符号位
                    compare = operand1_i[31] ? 32'h1 : 32'h0;  
                end else begin
                    compare = operand1_i < operand2_i ? 32'h1 : 32'h0;
                end
            end
            `EXE_SLTU: compare = operand1_i < operand2_i ? 32'h1 : 32'h0;
            default:   compare = `ZeroWord;
        endcase
    end

    // shift
    always @ (*) begin
        case (aluop_i)
            `EXE_SLL: shiftres    = (operand1_i << operand2_i[4:0]);
            `EXE_SRL: shiftres    = (operand1_i >> operand2_i[4:0]);
            `EXE_SRA: shiftres    = (({32{operand1_i[31]}} << (6'd32 - {1'b0, operand2_i[4:0]})) | (operand1_i >> operand2_i[4:0]));
            `EXE_LUI: shiftres    = operand2_i;
            default:  shiftres    = `ZeroWord;
        endcase
    end

    // branch 
    always @ (*) begin
        branch_flag     = `BranchDisable;
        branch_addr     = `ZeroWord;
        branchres       = `ZeroWord;
        case (aluop_i)
            `EXE_BEQ: begin
                if (operand1_i == operand2_i) begin
                    branch_flag   = `BranchEnable;
                    branch_addr   = pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                end
            end 
            `EXE_BNE: begin
                if (operand1_i != operand2_i) begin
                    branch_flag   = `BranchEnable;
                    branch_addr   = pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                end
            end
            `EXE_BLT: begin
                if (operand1_i[31] != operand2_i[31]) begin
                    branch_flag   = (operand1_i[31] ? `BranchEnable : `BranchDisable);
                    branch_addr   = pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                end else if (operand1_i < operand2_i) begin
                    branch_flag   = `BranchEnable;
                    branch_addr   = pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0}; 
                end
            end
            `EXE_BGE: begin
                if (operand1_i[31] != operand2_i[31]) begin
                    branch_flag   = (operand1_i[31] ? `BranchDisable : `BranchEnable);
                    branch_addr   = pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                end else if (operand1_i < operand2_i) begin
                end else begin
                    branch_flag   = `BranchEnable;
                    branch_addr   = pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                end
            end
            `EXE_BLTU: begin
                if (operand1_i < operand2_i) begin
                    branch_flag   = `BranchEnable;
                    branch_addr   = pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                end
            end
            `EXE_BGEU: begin
                if (operand1_i < operand2_i) begin
                end else begin
                    branch_flag   = `BranchEnable;
                    branch_addr   = pc_i + {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                end
            end
            `EXE_JAL:  begin
                branch_flag     = `BranchEnable;
                branch_addr     = pc_i + {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
                branchres       = pc_i + 4'h4;
            end
            `EXE_JALR: begin
                branch_flag     = `BranchEnable;
                branch_addr     = (operand1_i + {{20{inst_i[31]}}, inst_i[31:20]}) & (32'hfffffffe);
                branchres       = pc_i + 4'h4;
            end
            default: begin
                branch_flag     = `BranchDisable;
                branch_addr     = `ZeroWord;
                branchres       = `ZeroWord;
            end
        endcase
    end

    // csrr
	assign wcsr_o = (int_assert_i == `INT_ASSERT) ? `WriteDisable : wcsr_i;    
    assign wcsr_addr_o = wcsr_addr_i;

    always @(*) begin
        case (aluop_i)
            `EXE_CSRRW: wcsr_data_o = operand1_i;
            `EXE_CSRRS: wcsr_data_o = csr_data_i | operand1_i;
            `EXE_CSRRC: wcsr_data_o = csr_data_i & (~operand1_i);
            default:    wcsr_data_o = `ZeroWord;
        endcase
    end


    // 2. 根据 alusel_i 指示的运算类型，选择一个运算结果作为最终结果
    always @ (*) begin
        wreg      = wreg_i;         // wreg_o 等于 wreg_i,表示是否要写目的寄存器
        wreg_addr = wreg_addr_i;    // wreg_addr_o 等于 wreg_addr_i, 要写的目的寄存器地址
        case (alusel_i)
            `EXE_RES_LOGIC:     wreg_data = logicout;    // wreg_data_o 中存放运算结果
            `EXE_RES_COMPARE:   wreg_data = compare;  
            `EXE_RES_SHIFT:     wreg_data = shiftres;
            `EXE_RES_ARITH:     wreg_data = arithresult;
            `EXE_RES_BRANCH:    wreg_data = branchres;
            `EXE_RES_CSR:       wreg_data = csr_data_i;
            default:            wreg_data = `ZeroWord;
        endcase
    end

endmodule // ex
