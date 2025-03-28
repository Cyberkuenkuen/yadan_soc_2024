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
    input   wire        rst_n,

    // from if
    input   wire[`InstAddrBus]      pc_i,   // from pc_reg
    input   wire[`InstBus]          inst_i, // from cpu_ahb_if

    // from ex
    // input   wire                    ex_branch_flag_i,

    // from ctrl
    // input   wire[4:0]           stalled_i,
    // input   wire[4:0]           flush_i,
    input   wire                stalled_i,
    input   wire                flush_i,

    // to id
    output  reg[`InstAddrBus]       pc_o,
    output  reg[`InstBus]           inst_o
);

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == `RstEnable) begin
            pc_o    <= `ZeroWord;
            inst_o  <= `ZeroWord;
        end else begin
            // if (ex_branch_flag_i == `BranchEnable) begin
            // if (flush_i[1] == 1) begin
            if (flush_i == 1) begin
                pc_o    <= `ZeroWord;
                inst_o  <= `ZeroWord;
            // end else if (stalled_i[1] == `NoStop) begin
            end else if (stalled_i == `NoStop) begin
                pc_o    <= pc_i;
                inst_o  <= inst_i;
            // end else if (stalled_i[2] == `NoStop) begin
            // end else if (flush_i[1] == 1) begin
            //     pc_o    <= `ZeroWord;
            //     inst_o  <= `ZeroWord;
            end //else 保持不变
        end
    end

endmodule