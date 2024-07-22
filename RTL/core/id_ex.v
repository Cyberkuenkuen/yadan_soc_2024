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
    input   wire        rst,

    // 从译码段传递过来的信息
    input   wire[`InstAddrBus]  id_pc_i,
    input   wire[`InstBus]      id_inst_i,
    input   wire[`AluOpBus]     id_aluop,
    input   wire[`AluSelBus]    id_alusel,
    input   wire[`RegBus]       id_reg1,
    input   wire[`RegBus]       id_reg2,
    input   wire[`RegAddrBus]   id_wd,
    input   wire                id_wreg,
    input   wire                id_wcsr_reg,
    input   wire[`RegBus]       id_csr_reg,
    input   wire[`DataAddrBus]  id_wd_csr_reg,

    input   wire                ex_branch_flag_i,
    
    input   wire[5:0]           stalled,
    input   wire[5:0]           flush,


    // 传递到执行段的信息
    output  reg[`InstAddrBus]   ex_pc_o,
    output  reg[`InstBus]       ex_inst_o,
    output  reg[`AluOpBus]      ex_aluop,
    output  reg[`AluSelBus]     ex_alusel,
    output  reg[`RegBus]        ex_reg1,
    output  reg[`RegBus]        ex_reg2,
    output  reg[`RegAddrBus]    ex_wd,
    output  reg                 ex_wreg,
    output  reg                 ex_wcsr_reg,
    output  reg[`RegBus]        ex_csr_reg,
    output  reg[`DataAddrBus]   ex_wd_csr_reg
);

    always @ (posedge clk or negedge rst)  begin
        if (rst == `RstEnable) begin
            ex_pc_o         <= `ZeroWord;
            ex_inst_o       <= `ZeroWord;
            ex_aluop        <= `EXE_NONE;
            ex_alusel       <= `EXE_RES_NONE;
            ex_reg1         <= `ZeroWord;
            ex_reg2         <= `ZeroWord;
            ex_wd           <= `NOPRegAddr;
            ex_wreg         <= `WriteDisable;
            ex_wcsr_reg     <= `WriteDisable;
            ex_csr_reg      <= `ZeroWord;
            ex_wd_csr_reg   <= `ZeroWord;
        end else if((stalled[2] == `Stop) && (stalled[3] == `NoStop)) begin
                ex_inst_o       <= `ZeroWord;
                ex_pc_o         <= `ZeroWord;
                ex_aluop        <= `EXE_NONE;
                ex_alusel       <= `EXE_RES_NONE;
                ex_reg1         <= `ZeroWord;
                ex_reg2         <= `ZeroWord;
                ex_wd           <= `NOPRegAddr;
                ex_wreg         <= `WriteDisable;
                ex_wcsr_reg     <= `WriteDisable;
                ex_csr_reg      <= `ZeroWord;
                ex_wd_csr_reg   <= `ZeroWord;
        end else if (flush[2] == `Stop )begin //|| (ex_branch_flag_i == `BranchEnable && id_inst_i != `ZeroWord))  begin
                ex_inst_o       <= `ZeroWord;
                ex_pc_o         <= `ZeroWord;
                ex_aluop        <= `EXE_NONE;
                ex_alusel       <= `EXE_RES_NONE;
                ex_reg1         <= `ZeroWord;
                ex_reg2         <= `ZeroWord;
                ex_wd           <= `NOPRegAddr;
                ex_wreg         <= `WriteDisable;
                ex_wcsr_reg     <= `WriteDisable;
                ex_csr_reg      <= `ZeroWord;
                ex_wd_csr_reg   <= `ZeroWord;
        end else if (stalled[2] == `NoStop) begin
                ex_pc_o         <= id_pc_i;
                ex_inst_o       <= id_inst_i;
                ex_aluop        <= id_aluop;
                ex_alusel       <= id_alusel;
                ex_reg1         <= id_reg1;
                ex_reg2         <= id_reg2;
                ex_wd           <= id_wd;
                ex_wreg         <= id_wreg;
                ex_wcsr_reg     <= id_wcsr_reg;
                ex_csr_reg      <= id_csr_reg;
                ex_wd_csr_reg   <= id_wd_csr_reg;
        end
        else begin
                ex_pc_o         <=  ex_pc_o       ;
                ex_inst_o       <=  ex_inst_o     ;
                ex_aluop        <=  ex_aluop      ;
                ex_alusel       <=  ex_alusel     ;
                ex_reg1         <=  ex_reg1       ;
                ex_reg2         <=  ex_reg2       ;
                ex_wd           <=  ex_wd         ;
                ex_wreg         <=  ex_wreg       ;
                ex_wcsr_reg     <=  ex_wcsr_reg   ;
                ex_csr_reg      <=  ex_csr_reg    ;
                ex_wd_csr_reg   <=  ex_wd_csr_reg ;
        end
    end
        

endmodule // id_ex
