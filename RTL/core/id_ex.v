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

module id_ex(
    input   wire        clk,
    input   wire        rst_n,

    // from id
    input   wire[`InstAddrBus]  id_pc_i,
    input   wire[`InstBus]      id_inst_i,
    input   wire[`AluOpBus]     id_aluop_i,
    input   wire[`AluSelBus]    id_alusel_i,
    input   wire[`RegBus]       id_operand1_i,
    input   wire[`RegBus]       id_operand2_i,
    input   wire[`RegAddrBus]   id_wreg_addr_i,
    input   wire                id_wreg_i,
    
    input   wire[`RegBus]       id_csr_data_i,
    input   wire                id_wcsr_i,
    input   wire[`DataAddrBus]  id_wcsr_addr_i,

    // from ex
    input   wire                ex_branch_flag_i,
    
    // from ctrl
    input   wire[4:0]           stalled_i,

    // to ex
    output  reg[`InstAddrBus]   ex_pc_o,
    output  reg[`InstBus]       ex_inst_o,
    output  reg[`AluOpBus]      ex_aluop_o,
    output  reg[`AluSelBus]     ex_alusel_o,
    output  reg[`RegBus]        ex_operand1_o,
    output  reg[`RegBus]        ex_operand2_o,
    output  reg                 ex_wreg_o,
    output  reg[`RegAddrBus]    ex_wreg_addr_o,
    
    output  reg[`RegBus]        ex_csr_data_o,
    output  reg                 ex_wcsr_o,
    output  reg[`DataAddrBus]   ex_wcsr_addr_o
);

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == `RstEnable) begin
            ex_pc_o         <= `ZeroWord;
            ex_inst_o       <= `ZeroWord;
            ex_aluop_o      <= `EXE_NONE;
            ex_alusel_o     <= `EXE_RES_NONE;
            ex_operand1_o   <= `ZeroWord;
            ex_operand2_o   <= `ZeroWord;
            ex_wreg_o       <= `WriteDisable;
            ex_wreg_addr_o  <= `NOPRegAddr;
            ex_csr_data_o   <= `ZeroWord;
            ex_wcsr_o       <= `WriteDisable;
            ex_wcsr_addr_o  <= `ZeroWord;
        end else begin
            if (ex_branch_flag_i == `BranchEnable) begin
                ex_inst_o       <= `ZeroWord;
                ex_pc_o         <= `ZeroWord;
                ex_aluop_o      <= `EXE_NONE;
                ex_alusel_o     <= `EXE_RES_NONE;
                ex_operand1_o   <= `ZeroWord;
                ex_operand2_o   <= `ZeroWord;
                ex_wreg_o       <= `WriteDisable;
                ex_wreg_addr_o  <= `NOPRegAddr;
                ex_csr_data_o   <= `ZeroWord;
                ex_wcsr_o       <= `WriteDisable;
                ex_wcsr_addr_o  <= `ZeroWord;
            // 不停顿，正常传递
            end else if (stalled_i[2] == `NoStop) begin
                ex_pc_o         <= id_pc_i;
                ex_inst_o       <= id_inst_i;
                ex_aluop_o      <= id_aluop_i;
                ex_alusel_o     <= id_alusel_i;
                ex_operand1_o   <= id_operand1_i;
                ex_operand2_o   <= id_operand2_i;
                ex_wreg_o       <= id_wreg_i;
                ex_wreg_addr_o  <= id_wreg_addr_i;
                ex_csr_data_o   <= id_csr_data_i;
                ex_wcsr_o       <= id_wcsr_i;
                ex_wcsr_addr_o  <= id_wcsr_addr_i;
            // 停顿，同时执行阶段不停顿，清空所有译码结果
            end else if(stalled_i[3] == `NoStop) begin
                ex_inst_o       <= `ZeroWord;
                ex_pc_o         <= `ZeroWord;
                ex_aluop_o      <= `EXE_NONE;
                ex_alusel_o     <= `EXE_RES_NONE;
                ex_operand1_o   <= `ZeroWord;
                ex_operand2_o   <= `ZeroWord;
                ex_wreg_o       <= `WriteDisable;
                ex_wreg_addr_o  <= `NOPRegAddr;
                ex_csr_data_o   <= `ZeroWord;
                ex_wcsr_o       <= `WriteDisable;
                ex_wcsr_addr_o  <= `ZeroWord;
            end // else 译码阶段和执行阶段均停顿，保持不变
        end
    end
    
endmodule // id_ex
