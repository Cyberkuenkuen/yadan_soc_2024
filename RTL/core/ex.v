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
    input   wire            rst,

    // from id/ex 译码阶段送到执行阶段的信息
    input   wire[`InstAddrBus]  ex_pc,
    input   wire[`InstBus]      ex_inst,
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`AluSelBus]    alusel_i,
    input   wire[`RegBus]       reg1_i,
    input   wire[`RegBus]       reg2_i,
    input   wire[`RegAddrBus]   wd_i,
    input   wire                wreg_i,
    input   wire                wcsr_reg_i,
    input   wire[`RegBus]       csr_reg_i,
    input   wire[`DataAddrBus]  wd_csr_reg_i,

    //from mul/div
    
    input   wire[`DoubleRegBus] muldiv_result_i,
    input   wire                muldiv_done,
    // input   wire[`RegAddrBus]   div_reg_waddr_i,

    input wire int_assert_i,                // 中断发生标志
    input wire[`InstAddrBus] int_addr_i,    // 中断跳转地址

    //to mul/div
    output  reg                 muldiv_start_o,
    output  reg[`RegBus]        muldiv_dividend_o,
    output  reg[`RegBus]        muldiv_divisor_o,
    output  reg                 mul_or_div,
    output  reg                 muldiv_reg1_signed0_unsigned1,
    output  reg                 muldiv_reg2_signed0_unsigned1,


    // 执行结果 to ex_mem
    output  wire[`RegAddrBus]    wd_o,       //写寄存器地址
    output  wire                 wreg_o,     //写寄存器使能
    output  wire[`RegBus]        wdata_o,    //写寄存器数据

    output  reg[`AluOpBus]      ex_aluop_o,
    output  reg[`DataAddrBus]   ex_mem_addr_o,
    output  reg[`RegBus]        ex_reg2_o,

    // output to csr_reg
    output  wire                wcsr_reg_o,         // write csr enable
    output  wire[`DataAddrBus]  wd_csr_reg_o,
    output  reg[`RegBus]        wcsr_data_o,   

    // output  pc_reg / ctrl
    
    output  wire                 branch_flag_o,
    output  wire[`RegBus]        branch_addr_o
);

    reg[`RegAddrBus]        wd;   
    reg                     wreg; 
    reg[`RegBus]            wdata;
    reg                     branch_flag;
    reg[`InstAddrBus]       branch_addr;
    //寄存器
    assign  wd_o            =   wd;
    assign  wreg_o          =   (int_assert_i == `INT_ASSERT)? `WriteDisable: wreg;
    assign  wdata_o         =   wdata;



    assign  branch_flag_o   =   branch_flag ||  ((int_assert_i == `INT_ASSERT)? `BranchEnable: `BranchDisable);
    assign  branch_addr_o   =   (int_assert_i == `INT_ASSERT)? int_addr_i: branch_addr;

    // 相减结果
    wire[31:0]      exe_res_sub = reg1_i - reg2_i;

    // 保存逻辑运算的结果
    reg[`RegBus]    logicout;
    reg[`RegBus]    compare;        // 比较结果
    reg[`RegBus]    shiftres;       // 移位结果
    reg[`RegBus]    arithresult;       // 算术结果
    reg[`RegBus]    branchres;      // 跳转回写偏移结果



    //arith
    always @(*) begin
            if (muldiv_done) begin   // mul/div 运算结束
                muldiv_start_o                  =  1'b0;
                mul_or_div                      =  `MUL;
                muldiv_dividend_o               =  `ZeroWord;
                muldiv_divisor_o                =  `ZeroWord;
                muldiv_reg1_signed0_unsigned1   = `Unsigned;
                muldiv_reg2_signed0_unsigned1   = `Unsigned; 
                case (aluop_i)
                    `EXE_DIV,`EXE_DIVU,`EXE_MULHU,`EXE_MULH,`EXE_MULHSU  : begin
                    arithresult      =  muldiv_result_i[63:32]; 
                    end 
                    `EXE_REM,`EXE_REMU, `EXE_MUL : begin
                        arithresult     =  muldiv_result_i[31:0];
                    end
                    `EXE_ADD: begin
                        arithresult     = (reg1_i + reg2_i);
                    end 
                    `EXE_SUB: begin
                        arithresult     = (reg1_i - reg2_i);
                    end      
                    default: 
                        arithresult     = `ZeroWord;
                endcase
                
            end else begin     //mul/div 没有运行或没有运行结束
                arithresult                     = `ZeroWord;
                muldiv_start_o                  =  1'b0;
                mul_or_div                      =  `MUL;
                muldiv_dividend_o               =  `ZeroWord;
                muldiv_divisor_o                =  `ZeroWord;
                muldiv_reg1_signed0_unsigned1   = `Unsigned;
                muldiv_reg2_signed0_unsigned1   = `Unsigned; 
                case (aluop_i)
                    `EXE_DIV,`EXE_REM  : begin
                        muldiv_start_o                  =  1'b1;
                        mul_or_div                      =  `DIV;
                        muldiv_dividend_o               =  reg1_i;
                        muldiv_divisor_o                =  reg2_i;
                        muldiv_reg1_signed0_unsigned1   = `Signed;
                        muldiv_reg2_signed0_unsigned1   = `Signed;
                        
                    end
                    `EXE_DIVU,`EXE_REMU : begin
                        muldiv_start_o                  =  1'b1;
                        mul_or_div                      =  `DIV;
                        muldiv_dividend_o               =  reg1_i;
                        muldiv_divisor_o                =  reg2_i;
                        muldiv_reg1_signed0_unsigned1   = `Unsigned;
                        muldiv_reg2_signed0_unsigned1   = `Unsigned;
                        
                    end
                    
                    `EXE_MUL,`EXE_MULHU  : begin
                        muldiv_start_o                  =  1'b1;
                        mul_or_div                      =  `MUL;
                        muldiv_dividend_o               =  reg1_i;
                        muldiv_divisor_o                =  reg2_i;
                        muldiv_reg1_signed0_unsigned1   = `Unsigned;
                        muldiv_reg2_signed0_unsigned1   = `Unsigned;
                        
                    end
                    `EXE_MULH:  begin
                        muldiv_start_o                  =  1'b1;
                        mul_or_div                      =  `MUL;
                        muldiv_dividend_o               =  reg1_i;
                        muldiv_divisor_o                =  reg2_i;
                        muldiv_reg1_signed0_unsigned1   = `Signed;
                        muldiv_reg2_signed0_unsigned1   = `Signed;
                        
                    end
                    `EXE_MULHSU: begin
                        muldiv_start_o                  =  1'b1;
                        mul_or_div                      =  `MUL;
                        muldiv_dividend_o               =  reg1_i;
                        muldiv_divisor_o                =  reg2_i;
                        muldiv_reg1_signed0_unsigned1   = `Signed;
                        muldiv_reg2_signed0_unsigned1   = `Unsigned;
                        
                    end
                    
                    `EXE_ADD: begin
                        arithresult                     = (reg1_i + reg2_i);
                        
                    end 
                    `EXE_SUB: begin
                        arithresult                     = (reg1_i - reg2_i);
                        
                    end

                    default: begin
                        muldiv_start_o                  =  1'b0;
                        mul_or_div                      =  `MUL;
                        muldiv_dividend_o               =  `ZeroWord;
                        muldiv_divisor_o                =  `ZeroWord;
                        muldiv_reg1_signed0_unsigned1   = `Unsigned;
                        muldiv_reg2_signed0_unsigned1   = `Unsigned; 
                        arithresult                     = `ZeroWord;
                    end
                        
                endcase
            end
    end

    // aluop 传递到 访存阶段
    always @ (*) begin
            ex_aluop_o  = aluop_i;
            ex_reg2_o   = reg2_i; 
            case (alusel_i)
                `EXE_RES_LOAD: begin
                    ex_mem_addr_o   = (reg1_i + {{20{ex_inst[31]}}, ex_inst[31:20]});
                end
                `EXE_RES_STORE: begin
                    ex_mem_addr_o   = (reg1_i + {{20{ex_inst[31]}}, ex_inst[31:25], ex_inst[11:7]});
                end
                default: begin
                    ex_mem_addr_o   = `ZeroWord;
                end
            endcase
    end

    
    // 1. 根据 aluop_i 指示的运算子类型进行运算 
    // logic 
    always @ (*) begin
            case (aluop_i)
                `EXE_AND: begin
                    logicout    = (reg1_i & reg2_i);
                end
                `EXE_OR: begin
                    logicout    = (reg1_i | reg2_i);
                end 
                `EXE_XOR: begin
                    logicout    = (reg1_i ^ reg2_i);
                end
                default:   begin
                    logicout    = `ZeroWord;
                end
            endcase
    end // always

    // compare
    always @ (*) begin
            case (aluop_i)
                `EXE_SLT:  begin
                    if (reg1_i[31] != reg2_i[31]) begin
                        compare = (reg1_i[31] ? 32'h1 : 32'h0);
                    end else begin
                        compare = (exe_res_sub[31] ? 32'h1 : 32'h0);
                    end
                end 
                `EXE_SLTU: begin
                    compare = ((reg1_i < reg2_i) ? 32'h1 : 32'h0);
                end
                default: begin
                    compare = `ZeroWord;
                end
            endcase
    end

    // shift
    always @ (*) begin
            case (aluop_i)
                `EXE_SLL: begin
                    shiftres    = (reg1_i << reg2_i[4:0]);
                end
                `EXE_SRL: begin
                    shiftres    = (reg1_i >> reg2_i[4:0]);
                end 
                `EXE_SRA: begin
                    shiftres    = (({32{reg1_i[31]}} << (6'd32 - {1'b0, reg2_i[4:0]})) | (reg1_i >> reg2_i[4:0]));
                end
                `EXE_LUI: begin
                    shiftres    = reg2_i;
                end
                default: begin
                    shiftres    = `ZeroWord;
                end
            endcase
    end

    // branch 
    always @ (*) begin
            branch_addr     = `ZeroWord;
            branchres       = `ZeroWord;
            case (aluop_i)
                `EXE_BEQ: begin
                    if (reg1_i == reg2_i) begin
                        branch_flag   = `BranchEnable;
                        branch_addr   = ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else begin
                        branch_flag   = `BranchDisable;
                        
                    end
                end 
                `EXE_BNE: begin
                    if (reg1_i != reg2_i) begin
                        branch_flag   = `BranchEnable;
                        branch_addr   = ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else begin
                        branch_flag   = `BranchDisable;
                        
                    end
                end
                `EXE_BLT: begin
                    if (reg1_i[31] != reg2_i[31]) begin
                        branch_flag   = (reg1_i[31] ? `BranchEnable : `BranchDisable);
                        branch_addr   = ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else if (reg1_i < reg2_i) begin
                        branch_flag   = `BranchEnable;
                        branch_addr   = ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0}; 
                    end else begin
                        branch_flag   = `BranchDisable;
                        
                    end
                end
                `EXE_BGE: begin
                    if (reg1_i[31] != reg2_i[31]) begin
                        branch_flag   = (reg1_i[31] ? `BranchDisable : `BranchEnable);
                        branch_addr   = ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else if (reg1_i < reg2_i) begin
                        branch_flag   = `BranchDisable;
                        
                    end else begin
                        branch_flag   = `BranchEnable;
                        branch_addr   = ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end
                end
                `EXE_BLTU: begin
                    if (reg1_i[31] != reg2_i[31]) begin
                        branch_flag   = (reg1_i[31] ? `BranchDisable : `BranchEnable);
                        branch_addr   = ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else if (reg1_i < reg2_i) begin
                        branch_flag   = `BranchEnable;
                        branch_addr   = ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end else begin
                        branch_flag   = `BranchDisable;
                        
                    end
                end
                `EXE_BGEU: begin
                    if (reg1_i[31] != reg2_i[31]) begin
                        branch_flag   = (reg1_i[31] ? `BranchEnable : `BranchDisable);
                        branch_addr   = ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0}; 
                    end else if (reg1_i < reg2_i) begin
                        branch_flag   = `BranchDisable;
                        
                    end else begin
                        branch_flag   = `BranchEnable;
                        branch_addr   = ex_pc + {{20{ex_inst[31]}}, ex_inst[7], ex_inst[30:25], ex_inst[11:8], 1'b0};
                    end
                end
                `EXE_JAL:  begin
                    branch_flag     = `BranchEnable;
                    branch_addr     = ex_pc + {{12{ex_inst[31]}}, ex_inst[19:12], ex_inst[20], ex_inst[30:21], 1'b0};
                    branchres       = ex_pc + 4'h4;
                end
                `EXE_JALR: begin
                    branch_flag     = `BranchEnable;
                    branch_addr     = (reg1_i + {{20{ex_inst[31]}}, ex_inst[31:20]}) & (32'hfffffffe);
                    branchres       = ex_pc + 4'h4;
                end

                default: begin
                    branch_flag     = `BranchDisable;
                    branch_addr     = `ZeroWord;
                    branchres       = `ZeroWord;
                end
            endcase
    end

    // csrr
	assign wcsr_reg_o =  (int_assert_i == `INT_ASSERT)? `WriteDisable   :   wcsr_reg_i;    
    assign wd_csr_reg_o = wd_csr_reg_i;

    always @ (*) begin
            case (aluop_i)
                `EXE_CSRRW: begin
                    wcsr_data_o = reg1_i;
                end
                `EXE_CSRRS: begin
                    wcsr_data_o = csr_reg_i | reg1_i;
                end
                `EXE_CSRRC: begin
                    wcsr_data_o = csr_reg_i & (~reg1_i);
                end
                default: begin
                    wcsr_data_o = `ZeroWord;
                end
            endcase
    end


    // 2. 根据 alusel_i 指示的运算类型，选择一个运算结果作为最终结果
    always @ (*) begin
        wd    = wd_i;    // wd_o 等于 wd_i, 要写的目的寄存器地址
        wreg  = wreg_i;  // wreg_o 等于 wreg_i,表示是否要写目的寄存器
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata = logicout;    // wdata_o 中存放运算结果
            end 
            `EXE_RES_COMPARE: begin
                wdata = compare;  
            end
            `EXE_RES_SHIFT: begin
                wdata = shiftres;
            end
            `EXE_RES_ARITH: begin
                wdata = arithresult;
            end
            `EXE_RES_BRANCH: begin
                wdata = branchres;
            end
            `EXE_RES_CSR   : begin
                wdata = csr_reg_i;
            end
            default:    begin
                wdata = `ZeroWord;
            end
        endcase
    end

endmodule // ex
