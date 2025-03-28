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

module pc_reg(
    input   wire             clk,
    input   wire             rst_n,

    // from mem
    input   wire             PCchange_enable_i,

    // from ex
    input   wire             ex_branch_flag_i,
    input   wire[`RegBus]    ex_branch_addr_i,

    // from ctrl
    // input   wire[4:0]           stalled_i,
    // input   wire[4:0]           flush_i,
    input   wire                stalled_i,
    input   wire                flush_i,

    // to if_id
    output  reg[`InstAddrBus]pc_o,
    
    // to cpu_ahb_if
    output  wire             ce_o
);

    assign  ce_o = PCchange_enable_i;

    always @(posedge clk or negedge rst_n) begin
        if(rst_n == `RstEnable) begin
            pc_o <= `StartAdd;
        end else begin
            if(ex_branch_flag_i == `BranchEnable) begin
                pc_o <= ex_branch_addr_i;
            // 优先根据跳转信号更新pc，如果在取指阶段发生流水线停顿，跳转信号不会因此丢失
            // end else if(stalled_i[0] == `NoStop) begin
            end else if(stalled_i == `NoStop) begin
                if(pc_o < `INSTADD_END) begin
                    pc_o <= pc_o + 4'h4;
                end else begin
                    pc_o <= `StartAdd;
                end
            end else begin
                pc_o  <=  pc_o;
            end
        end
    end

endmodule // pc_reg
