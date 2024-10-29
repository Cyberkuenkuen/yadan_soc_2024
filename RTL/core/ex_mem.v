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

module ex_mem(
    input   wire        clk,
    input   wire        rst_n,

    // from ex
    input   wire                ex_wreg_i,
    input   wire[`RegAddrBus]   ex_wreg_addr_i,
    input   wire[`RegBus]       ex_wreg_data_i,

    input   wire[`AluOpBus]     ex_aluop_i,
    input   wire[`DataAddrBus]  ex_memaddr_i,
    input   wire[`RegBus]       ex_operand2_i,

    // input   wire[4:0]           stalled_i,
    // input   wire[4:0]           flush_i,
    input   wire                stalled_i,
    input   wire                flush_i,

    // to mem
    output  reg                 mem_wreg_o,
    output  reg[`RegAddrBus]    mem_wreg_addr_o,
    output  reg[`RegBus]        mem_wreg_data_o,

    output  reg[`AluOpBus]      mem_aluop_o,
    output  reg[`DataAddrBus]   mem_memaddr_o,
    output  reg[`RegBus]        mem_operand2_o
);

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == `RstEnable) begin
            mem_wreg_o          <= `WriteDisable;
            mem_wreg_addr_o     <= `NOPRegAddr;
            mem_wreg_data_o     <= `ZeroWord;
            mem_aluop_o         <= `EXE_NONE;
            mem_memaddr_o       <= `ZeroWord;
            mem_operand2_o      <= `ZeroWord;
        end else begin
            // if (flush_i[3] == 1) begin
            if (flush_i == 1) begin
                mem_wreg_o          <= `WriteDisable;
                mem_wreg_addr_o     <= `NOPRegAddr;
                mem_wreg_data_o     <= `ZeroWord;
                mem_aluop_o         <= `EXE_NONE;
                mem_memaddr_o       <= `ZeroWord;
                mem_operand2_o      <= `ZeroWord;
            // end else if (stalled_i[3] == `NoStop) begin
            end else if (stalled_i == `NoStop) begin
                mem_wreg_o          <= ex_wreg_i;
                mem_wreg_addr_o     <= ex_wreg_addr_i;
                mem_wreg_data_o     <= ex_wreg_data_i;
                mem_aluop_o         <= ex_aluop_i;
                mem_memaddr_o       <= ex_memaddr_i;
                mem_operand2_o      <= ex_operand2_i;
            // end else if (stalled_i[4] == `NoStop) begin
            //     mem_wreg_o          <= `WriteDisable;
            //     mem_wreg_addr_o     <= `NOPRegAddr;
            //     mem_wreg_data_o     <= `ZeroWord;
            //     mem_aluop_o         <= `EXE_NONE;
            //     mem_memaddr_o       <= `ZeroWord;
            //     mem_operand2_o      <= `ZeroWord;
            end //else 保持不变
        end
    end
    
endmodule // ex_mem
