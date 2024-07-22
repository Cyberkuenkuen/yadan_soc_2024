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
    input       wire                clk,
    input       wire                rst,
    input       wire                PCchange_enable,
    input       wire                set_mode,

    input       wire                branch_flag_i,
    input       wire[`RegBus]       branch_addr_i,
    input       wire[5:0]           stalled,

    output      reg[`InstAddrBus]   pc_o,
    output      wire                ce_o 
);

    assign  ce_o = PCchange_enable;

    always  @ (posedge clk) begin
        if(rst == `RstEnable) begin
            if(set_mode) begin
                pc_o    <=  `StartAdd;
            end
            else begin
                pc_o    <=  `ZeroWord;
            end 
        end       
        else begin 
            if (branch_flag_i == `BranchEnable) begin
                pc_o    <= branch_addr_i;
                end 
                else if (PCchange_enable == 1'b0) begin
                    pc_o    <=  pc_o;
                    end 
                    else if (stalled[0] == `NoStop) begin
                            if(pc_o<=`INSTADD_END) begin
                                pc_o    <= pc_o + 4'h4;
                            end
                            else begin
                                pc_o  <=  `StartAdd;
                            end
                        end
                        else begin
                            pc_o    <=  pc_o;
                        end
        end
    end



endmodule // pc_reg
