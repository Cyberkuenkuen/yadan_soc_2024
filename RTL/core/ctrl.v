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

module ctrl(
    input   wire                stallreq_from_id_i,
    input   wire                stallreq_from_ex_i,
    input   wire                stallreq_from_if_i,
    input   wire                stallreq_from_mem_i,
    input   wire                stallreq_from_interrupt_i,

    input   wire                ex_branch_flag_i,
    output  reg[4:0]            stalled_o
);

    always @(*) begin
        if (stallreq_from_mem_i == `Stop) begin //&& ex_branch_flag_i == `BranchDisable) begin  
            stalled_o   =  5'b11111;
        end else if (stallreq_from_ex_i == `Stop) begin
            stalled_o   =  5'b01111;
        end else if (stallreq_from_id_i == `Stop || stallreq_from_interrupt_i == `Stop) begin    
            stalled_o   =  5'b00111;
        end else if (stallreq_from_if_i == `Stop) begin
            stalled_o   =  5'b00011;
        end else begin
            stalled_o   =  5'b00000;
        end
    end

endmodule // ctrl
