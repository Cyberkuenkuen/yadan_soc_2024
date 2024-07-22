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

module if_id(
    input   wire        clk,  
    input   wire        rst,

    // 来自取指阶段的信号
    input   wire[`InstAddrBus]      pc_i,
    input   wire[`InstBus]          inst_i,

    input   wire                    ex_branch_flag_i,
    input   wire[5:0]               stalled,
    input   wire[5:0]               flush,

    // 对应译码阶段的信号
    output  reg[`InstAddrBus]       pc_o,
    output  reg[`InstBus]           inst_o
);

    always @ (posedge clk or negedge rst)  begin
        if (rst == `RstEnable) begin
            pc_o    <= `ZeroWord;
            inst_o  <= `ZeroWord;
        end else if (stalled[1] == `Stop && stalled[2] == `NoStop) begin
            pc_o    <= `ZeroWord;//pc_o;
            inst_o  <= `ZeroWord;
        end else if (flush[1] == `Stop || ex_branch_flag_i == `BranchEnable) begin
            pc_o    <= pc_i;//`ZeroWord;
            inst_o  <= `ZeroWord;
        end  
        else if (stalled[1] == `NoStop) begin
            pc_o    <= pc_i;
            inst_o  <= inst_i;
        end
    end

endmodule
