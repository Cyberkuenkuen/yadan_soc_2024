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

`include "../core/yadan_defs.v"

module data_ram(
    input   wire                clk,
    input   wire                rst,
    input   wire                ce,

    input   wire                we,
    input   wire[`DataAddrBus]  addr,
    input   wire[2:0]           sel,
    input   wire[`DataBus]      data_i,
    

    output  reg[`DataBus]       data_o
);

    reg[`DataBus]       data_mem[0:`DataMemNum - 1];
    // reg[`ByteWidth]     data_mem0[0:`DataMemNum - 1];
    // reg[`ByteWidth]     data_mem1[0:`DataMemNum - 1];
    // reg[`ByteWidth]     data_mem2[0:`DataMemNum - 1];
    // reg[`ByteWidth]     data_mem3[0:`DataMemNum - 1];



    // write 
    always @ (posedge clk or negedge rst) begin
        if (rst == `RstEnable) begin
            
        end else begin
            if (we == `WriteEnable) begin
                if(sel == 3'b000) begin
                    // data_mem[addr[`DataMemNumLog2+1 : 2]] <= data_i;
                    if (addr[1:0] == 2'b00) begin
                        data_mem[addr[`DataMemNumLog2+1 : 2]][7:0] <= data_i[7:0];
                    end
                    if (addr[1:0] == 2'b01) begin
                        data_mem[addr[`DataMemNumLog2+1 : 2]][15:8] <= data_i[7:0];
                    end
                    if (addr[1:0] == 2'b10) begin
                        data_mem[addr[`DataMemNumLog2+1 : 2]][23:16] <= data_i[7:0];
                    end
                    if (addr[1:0] == 2'b11) begin
                        data_mem[addr[`DataMemNumLog2+1 : 2]][31:24] <= data_i[7:0];
                    end
                end
                else if (sel == 3'b001) begin
                    if (addr[1:0] == 2'b00) begin
                        data_mem[addr[`DataMemNumLog2+1 : 2]][15:0] <= data_i[15:0];
                    end
                    if (addr[1:0] == 2'b10) begin
                        data_mem[addr[`DataMemNumLog2+1 : 2]][31:16] <= data_i[15:0];
                    end
                end
                else begin
                    data_mem[addr[`DataMemNumLog2+1 : 2]] <= data_i;
                end
            end 
        end
    end

    // read 
    always @ (*) begin
        if (ce == `ReadEnable) 
        begin
             data_o  <=  data_mem[addr[`DataMemNumLog2+1 : 2]];
        end
    end

endmodule // data_ram
