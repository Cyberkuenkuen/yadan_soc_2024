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
    output  wire[`RegBus]        rdata1_o,

    // read port 2
    input   wire                re2_i,
    input   wire[`RegAddrBus]   raddr2_i,
    output  wire[`RegBus]        rdata2_o
);

        reg [`RegBus] reg_r1_q;
        reg [`RegBus] reg_r2_q;
        reg [`RegBus] reg_r3_q;
        reg [`RegBus] reg_r4_q;
        reg [`RegBus] reg_r5_q;
        reg [`RegBus] reg_r6_q;
        reg [`RegBus] reg_r7_q;
        reg [`RegBus] reg_r8_q;
        reg [`RegBus] reg_r9_q;
        reg [`RegBus] reg_r10_q;
        reg [`RegBus] reg_r11_q;
        reg [`RegBus] reg_r12_q;
        reg [`RegBus] reg_r13_q;
        reg [`RegBus] reg_r14_q;
        reg [`RegBus] reg_r15_q;
        reg [`RegBus] reg_r16_q;
        reg [`RegBus] reg_r17_q;
        reg [`RegBus] reg_r18_q;
        reg [`RegBus] reg_r19_q;
        reg [`RegBus] reg_r20_q;
        reg [`RegBus] reg_r21_q;
        reg [`RegBus] reg_r22_q;
        reg [`RegBus] reg_r23_q;
        reg [`RegBus] reg_r24_q;
        reg [`RegBus] reg_r25_q;
        reg [`RegBus] reg_r26_q;
        reg [`RegBus] reg_r27_q;
        reg [`RegBus] reg_r28_q;
        reg [`RegBus] reg_r29_q;
        reg [`RegBus] reg_r30_q;
        reg [`RegBus] reg_r31_q;

        //Simulation 
        wire [`RegBus] x0_zero_w = 32'b0;
        wire [`RegBus] x1_ra_w   = reg_r1_q;
        wire [`RegBus] x2_sp_w   = reg_r2_q;
        wire [`RegBus] x3_gp_w   = reg_r3_q;
        wire [`RegBus] x4_tp_w   = reg_r4_q;
        wire [`RegBus] x5_t0_w   = reg_r5_q;
        wire [`RegBus] x6_t1_w   = reg_r6_q;
        wire [`RegBus] x7_t2_w   = reg_r7_q;
        wire [`RegBus] x8_s0_w   = reg_r8_q;
        wire [`RegBus] x9_s1_w   = reg_r9_q;
        wire [`RegBus] x10_a0_w  = reg_r10_q;
        wire [`RegBus] x11_a1_w  = reg_r11_q;
        wire [`RegBus] x12_a2_w  = reg_r12_q;
        wire [`RegBus] x13_a3_w  = reg_r13_q;
        wire [`RegBus] x14_a4_w  = reg_r14_q;
        wire [`RegBus] x15_a5_w  = reg_r15_q;
        wire [`RegBus] x16_a6_w  = reg_r16_q;
        wire [`RegBus] x17_a7_w  = reg_r17_q;
        wire [`RegBus] x18_s2_w  = reg_r18_q;
        wire [`RegBus] x19_s3_w  = reg_r19_q;
        wire [`RegBus] x20_s4_w  = reg_r20_q;
        wire [`RegBus] x21_s5_w  = reg_r21_q;
        wire [`RegBus] x22_s6_w  = reg_r22_q;
        wire [`RegBus] x23_s7_w  = reg_r23_q;
        wire [`RegBus] x24_s8_w  = reg_r24_q;
        wire [`RegBus] x25_s9_w  = reg_r25_q;
        wire [`RegBus] x26_s10_w = reg_r26_q;
        wire [`RegBus] x27_s11_w = reg_r27_q;
        wire [`RegBus] x28_t3_w  = reg_r28_q;
        wire [`RegBus] x29_t4_w  = reg_r29_q;
        wire [`RegBus] x30_t5_w  = reg_r30_q;
        wire [`RegBus] x31_t6_w  = reg_r31_q;
    
    wire we;
    assign we = we_i;//(int_assert_i == `INT_ASSERT)? `WriteDisable: we_i;

    //write
    always @(posedge clk or negedge rst) begin 
        if (rst == `RstEnable) begin
            reg_r1_q       <= 32'h00000000;
            reg_r2_q       <= 32'h00000000;
            reg_r3_q       <= 32'h00000000;
            reg_r4_q       <= 32'h00000000;
            reg_r5_q       <= 32'h00000000;
            reg_r6_q       <= 32'h00000000;
            reg_r7_q       <= 32'h00000000;
            reg_r8_q       <= 32'h00000000;
            reg_r9_q       <= 32'h00000000;
            reg_r10_q      <= 32'h00000000;
            reg_r11_q      <= 32'h00000000;
            reg_r12_q      <= 32'h00000000;
            reg_r13_q      <= 32'h00000000;
            reg_r14_q      <= 32'h00000000;
            reg_r15_q      <= 32'h00000000;
            reg_r16_q      <= 32'h00000000;
            reg_r17_q      <= 32'h00000000;
            reg_r18_q      <= 32'h00000000;
            reg_r19_q      <= 32'h00000000;
            reg_r20_q      <= 32'h00000000;
            reg_r21_q      <= 32'h00000000;
            reg_r22_q      <= 32'h00000000;
            reg_r23_q      <= 32'h00000000;
            reg_r24_q      <= 32'h00000000;
            reg_r25_q      <= 32'h00000000;
            reg_r26_q      <= 32'h00000000;
            reg_r27_q      <= 32'h00000000;
            reg_r28_q      <= 32'h00000000;
            reg_r29_q      <= 32'h00000000;
            reg_r30_q      <= 32'h00000000;
            reg_r31_q      <= 32'h00000000;
        end 
        else if ((we == `WriteEnable) && (waddr_i != `RegNumLog2'h0))
        begin
            if      (waddr_i == 5'd1) reg_r1_q <= wdata_i;
            if      (waddr_i == 5'd2) reg_r2_q <= wdata_i;
            if      (waddr_i == 5'd3) reg_r3_q <= wdata_i;
            if      (waddr_i == 5'd4) reg_r4_q <= wdata_i;
            if      (waddr_i == 5'd5) reg_r5_q <= wdata_i;
            if      (waddr_i == 5'd6) reg_r6_q <= wdata_i;
            if      (waddr_i == 5'd7) reg_r7_q <= wdata_i;
            if      (waddr_i == 5'd8) reg_r8_q <= wdata_i;
            if      (waddr_i == 5'd9) reg_r9_q <= wdata_i;
            if      (waddr_i == 5'd10) reg_r10_q <= wdata_i;
            if      (waddr_i == 5'd11) reg_r11_q <= wdata_i;
            if      (waddr_i == 5'd12) reg_r12_q <= wdata_i;
            if      (waddr_i == 5'd13) reg_r13_q <= wdata_i;
            if      (waddr_i == 5'd14) reg_r14_q <= wdata_i;
            if      (waddr_i == 5'd15) reg_r15_q <= wdata_i;
            if      (waddr_i == 5'd16) reg_r16_q <= wdata_i;
            if      (waddr_i == 5'd17) reg_r17_q <= wdata_i;
            if      (waddr_i == 5'd18) reg_r18_q <= wdata_i;
            if      (waddr_i == 5'd19) reg_r19_q <= wdata_i;
            if      (waddr_i == 5'd20) reg_r20_q <= wdata_i;
            if      (waddr_i == 5'd21) reg_r21_q <= wdata_i;
            if      (waddr_i == 5'd22) reg_r22_q <= wdata_i;
            if      (waddr_i == 5'd23) reg_r23_q <= wdata_i;
            if      (waddr_i == 5'd24) reg_r24_q <= wdata_i;
            if      (waddr_i == 5'd25) reg_r25_q <= wdata_i;
            if      (waddr_i == 5'd26) reg_r26_q <= wdata_i;
            if      (waddr_i == 5'd27) reg_r27_q <= wdata_i;
            if      (waddr_i == 5'd28) reg_r28_q <= wdata_i;
            if      (waddr_i == 5'd29) reg_r29_q <= wdata_i;
            if      (waddr_i == 5'd30) reg_r30_q <= wdata_i;
            if      (waddr_i == 5'd31) reg_r31_q <= wdata_i;
        end
    end

    //read reg1
    reg[`RegBus]        rdata1_r;
    reg[`RegBus]        rdata2_r;

    always @(*) begin
        if ((raddr1_i == waddr_i) && (we == `WriteEnable) && (re1_i == `ReadEnable)) begin
            rdata1_r = wdata_i;
        end
        else if (re1_i == `ReadEnable) begin
            case (raddr1_i)
                5'd1: rdata1_r = reg_r1_q;
                5'd2: rdata1_r = reg_r2_q;
                5'd3: rdata1_r = reg_r3_q;
                5'd4: rdata1_r = reg_r4_q;
                5'd5: rdata1_r = reg_r5_q;
                5'd6: rdata1_r = reg_r6_q;
                5'd7: rdata1_r = reg_r7_q;
                5'd8: rdata1_r = reg_r8_q;
                5'd9: rdata1_r = reg_r9_q;
                5'd10:rdata1_r = reg_r10_q;
                5'd11:rdata1_r = reg_r11_q;
                5'd12:rdata1_r = reg_r12_q;
                5'd13:rdata1_r = reg_r13_q;
                5'd14:rdata1_r = reg_r14_q;
                5'd15:rdata1_r = reg_r15_q;
                5'd16:rdata1_r = reg_r16_q;
                5'd17:rdata1_r = reg_r17_q;
                5'd18:rdata1_r = reg_r18_q;
                5'd19:rdata1_r = reg_r19_q;
                5'd20:rdata1_r = reg_r20_q;
                5'd21:rdata1_r = reg_r21_q;
                5'd22:rdata1_r = reg_r22_q;
                5'd23:rdata1_r = reg_r23_q;
                5'd24:rdata1_r = reg_r24_q;
                5'd25:rdata1_r = reg_r25_q;
                5'd26:rdata1_r = reg_r26_q;
                5'd27:rdata1_r = reg_r27_q;
                5'd28:rdata1_r = reg_r28_q;
                5'd29:rdata1_r = reg_r29_q;
                5'd30:rdata1_r = reg_r30_q;
                5'd31:rdata1_r = reg_r31_q;
                default : rdata1_r = 32'h00000000;
            endcase
        end
        else begin
            rdata1_r = `ZeroWord;
        end
    end

    //read reg2
        always @(*) begin
        if ((raddr2_i == waddr_i) && (we == `WriteEnable) && (re2_i == `ReadEnable)) begin
            rdata2_r = wdata_i;
        end
        else if (re2_i == `ReadEnable) begin
            case (raddr2_i)
                5'd1: rdata2_r = reg_r1_q;
                5'd2: rdata2_r = reg_r2_q;
                5'd3: rdata2_r = reg_r3_q;
                5'd4: rdata2_r = reg_r4_q;
                5'd5: rdata2_r = reg_r5_q;
                5'd6: rdata2_r = reg_r6_q;
                5'd7: rdata2_r = reg_r7_q;
                5'd8: rdata2_r = reg_r8_q;
                5'd9: rdata2_r = reg_r9_q;
                5'd10:rdata2_r = reg_r10_q;
                5'd11:rdata2_r = reg_r11_q;
                5'd12:rdata2_r = reg_r12_q;
                5'd13:rdata2_r = reg_r13_q;
                5'd14:rdata2_r = reg_r14_q;
                5'd15:rdata2_r = reg_r15_q;
                5'd16:rdata2_r = reg_r16_q;
                5'd17:rdata2_r = reg_r17_q;
                5'd18:rdata2_r = reg_r18_q;
                5'd19:rdata2_r = reg_r19_q;
                5'd20:rdata2_r = reg_r20_q;
                5'd21:rdata2_r = reg_r21_q;
                5'd22:rdata2_r = reg_r22_q;
                5'd23:rdata2_r = reg_r23_q;
                5'd24:rdata2_r = reg_r24_q;
                5'd25:rdata2_r = reg_r25_q;
                5'd26:rdata2_r = reg_r26_q;
                5'd27:rdata2_r = reg_r27_q;
                5'd28:rdata2_r = reg_r28_q;
                5'd29:rdata2_r = reg_r29_q;
                5'd30:rdata2_r = reg_r30_q;
                5'd31:rdata2_r = reg_r31_q;
                default : rdata2_r = 32'h00000000;
            endcase
        end
        else begin
            rdata2_r = `ZeroWord;
        end
    end

    //out
    assign  rdata1_o  =  rdata1_r;
    assign  rdata2_o  =  rdata2_r; 


endmodule // regsfile
