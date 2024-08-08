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

module mem_wb(
    input   wire            clk,
    input   wire            rst_n,

    // from mem
    input   wire                mem_wreg_i,
    input   wire[`RegAddrBus]   mem_wreg_addr_i,
    input   wire[`RegBus]       mem_wreg_data_i,

    // from ctrl
    input   wire[4:0]           stalled_i,

    // to regsfile (wb)
    output  reg                 wb_wreg_o,
    output  reg[`RegAddrBus]    wb_wreg_addr_o,
    output  reg[`RegBus]        wb_wreg_data_o
);

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == `RstEnable) begin
            wb_wreg_addr_o  <= `NOPRegAddr;
            wb_wreg_o       <= `WriteDisable;
            wb_wreg_data_o  <= `ZeroWord;
        end else if (stalled_i[4] == `NoStop) begin
            wb_wreg_addr_o  <= mem_wreg_addr_i;
            wb_wreg_o       <= mem_wreg_i;
            wb_wreg_data_o  <= mem_wreg_data_i;
        end
    end

endmodule // mem_wb
