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

module regsfile
(
    input   wire        clk,
    input   wire        rst,

    input wire int_assert_i,                // 中断发生标志

    // write port 回写
    input   wire                we_i,   
    input   wire[`RegAddrBus]   waddr_i,
    input   wire[`RegBus]       wdata_i,

    // read port 1
    input   wire                re1_i,
    input   wire[`RegAddrBus]   raddr1_i,
    output  wire[`RegBus]       rdata1_o,

    // read port 2
    input   wire                re2_i,
    input   wire[`RegAddrBus]   raddr2_i,
    output  wire[`RegBus]       rdata2_o
);

    // wire we;
    // assign we = we_i;//(int_assert_i == `INT_ASSERT)? `WriteDisable: we_i;

    reg [`RegBus] reg_Q [`RegNum-1:0];

    //write
    wire [`RegNum-1:0] we_Q;     //单个register写使能
    assign we_Q[0] = 1'b0;       //RV32I架构规定reg0的值只能为0，所以不能写入

    genvar i;
    generate
        for(i=1; i < `RegNum; i=i+1) begin
            assign we_Q[i] = (i == waddr_i) ? 1'b1 : 1'b0;
        end
    endgenerate

    generate
        for(i=0; i < `RegNum; i=i+1) begin
            always @(posedge clk or negedge rst) begin
                if(rst == `RstEnable)
                    reg_Q[i] <= 32'h00000000;
                else if(we_Q[i] && (we_i == `WriteEnable)) 
                    reg_Q[i] <= wdata_i;
            end
        end
    endgenerate

    //read port 1
    reg [`RegBus]   rdata1;
    reg [`RegBus]   rdata2;

    always @(*) begin
        if ((raddr1_i == waddr_i) && (we_i == `WriteEnable) && (re1_i == `ReadEnable)) begin
            rdata1 = wdata_i;
        end else if (re1_i == `ReadEnable) begin
            rdata1 = reg_Q[raddr1_i];
        end else begin
            rdata1 = `ZeroWord;
        end
    end

    //read port 2
    always @(*) begin
        if ((raddr2_i == waddr_i) && (we_i == `WriteEnable) && (re2_i == `ReadEnable)) begin
            rdata2 = wdata_i;
        end else if (re2_i == `ReadEnable) begin
            rdata2 = reg_Q[raddr2_i];
        end else begin
            rdata2 = `ZeroWord;
        end
    end

    //out
    assign  rdata1_o  =  rdata1;
    assign  rdata2_o  =  rdata2;

    //Simulation 
    wire [`RegBus] x0_zero_w = reg_Q[0];
    wire [`RegBus] x1_ra_w   = reg_Q[1];
    wire [`RegBus] x2_sp_w   = reg_Q[2];
    wire [`RegBus] x3_gp_w   = reg_Q[3];
    wire [`RegBus] x4_tp_w   = reg_Q[4];
    wire [`RegBus] x5_t0_w   = reg_Q[5];
    wire [`RegBus] x6_t1_w   = reg_Q[6];
    wire [`RegBus] x7_t2_w   = reg_Q[7];
    wire [`RegBus] x8_s0_w   = reg_Q[8];
    wire [`RegBus] x9_s1_w   = reg_Q[9];
    wire [`RegBus] x10_a0_w  = reg_Q[10];
    wire [`RegBus] x11_a1_w  = reg_Q[11];
    wire [`RegBus] x12_a2_w  = reg_Q[12];
    wire [`RegBus] x13_a3_w  = reg_Q[13];
    wire [`RegBus] x14_a4_w  = reg_Q[14];
    wire [`RegBus] x15_a5_w  = reg_Q[15];
    wire [`RegBus] x16_a6_w  = reg_Q[16];
    wire [`RegBus] x17_a7_w  = reg_Q[17];
    wire [`RegBus] x18_s2_w  = reg_Q[18];
    wire [`RegBus] x19_s3_w  = reg_Q[19];
    wire [`RegBus] x20_s4_w  = reg_Q[20];
    wire [`RegBus] x21_s5_w  = reg_Q[21];
    wire [`RegBus] x22_s6_w  = reg_Q[22];
    wire [`RegBus] x23_s7_w  = reg_Q[23];
    wire [`RegBus] x24_s8_w  = reg_Q[24];
    wire [`RegBus] x25_s9_w  = reg_Q[25];
    wire [`RegBus] x26_s10_w = reg_Q[26];
    wire [`RegBus] x27_s11_w = reg_Q[27];
    wire [`RegBus] x28_t3_w  = reg_Q[28];
    wire [`RegBus] x29_t4_w  = reg_Q[29];
    wire [`RegBus] x30_t5_w  = reg_Q[30];
    wire [`RegBus] x31_t6_w  = reg_Q[31];
    
endmodule // regsfile
